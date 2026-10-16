import 'package:flutter/material.dart';
import 'package:health_ai/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class RecordVisitScreen extends StatefulWidget {
  const RecordVisitScreen({super.key});

  @override
  State<RecordVisitScreen> createState() => _RecordVisitScreenState();
}

class _RecordVisitScreenState extends State<RecordVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _selectedPatient;
  List<Map<String, dynamic>> _patients = [];

  // Vital signs
  final _temperatureController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _pulseController = TextEditingController();

  // Symptoms
  final List<String> _commonSymptoms = [
    'Fever',
    'Cough',
    'Headache',
    'Fatigue',
    'Nausea',
    'Vomiting',
    'Diarrhea',
    'Abdominal pain',
    'Difficulty breathing',
    'Chest pain',
  ];
  final Set<String> _selectedSymptoms = {};

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _patientIdController.dispose();
    _diagnosisController.dispose();
    _temperatureController.dispose();
    _bloodPressureController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      final snapshot = await _firestore.collection('patients').get();
      setState(() {
        _patients = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'patientId': data['patientId'],
            'age': data['ageYears'],
            'sex': data['sex'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading patients: $e');
    }
  }

  Future<void> _recordVisit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get patient details
      final patientDoc = await _firestore.collection('patients').doc(_selectedPatient).get();
      final patientData = patientDoc.data()!;

      // Call Cloud Function for AI-powered risk prediction
      final callable = FirebaseFunctions.instance.httpsCallable('predictRisk');
      
      final result = await callable.call({
        'patientAge': patientData['age'] ?? 0,
        'sex': patientData['sex'] ?? 'unknown',
        'symptoms': _selectedSymptoms.toList(),
        'vitalSigns': {
          'temperature': _temperatureController.text.isEmpty
              ? null
              : double.tryParse(_temperatureController.text),
          'bloodPressure': _bloodPressureController.text.isEmpty
              ? null
              : _bloodPressureController.text,
          'pulse': _pulseController.text.isEmpty
              ? null
              : int.tryParse(_pulseController.text),
        },
        'diagnosis': _diagnosisController.text.trim(),
      });

      final prediction = result.data as Map<String, dynamic>;
      final riskLevel = prediction['riskLevel'] ?? 'medium';
      final riskScore = (prediction['riskScore'] ?? 0.5) as double;
      final riskFactors = List<String>.from(prediction['riskFactors'] ?? []);
      final recommendations = List<String>.from(prediction['recommendations'] ?? []);
      final aiReasoning = prediction['reasoning'] ?? '';
      final fallbackUsed = prediction['fallbackUsed'] == true;

      // Create visit record
      final visitRef = await _firestore.collection('visits').add({
        'patientId': _selectedPatient,
        'visitDate': FieldValue.serverTimestamp(),
        'diagnosis': _diagnosisController.text.trim(),
        'symptoms': _selectedSymptoms.toList(),
        'vitalSigns': {
          'temperature': _temperatureController.text.isEmpty
              ? null
              : double.tryParse(_temperatureController.text),
          'bloodPressure': _bloodPressureController.text.isEmpty
              ? null
              : _bloodPressureController.text,
          'pulse': _pulseController.text.isEmpty
              ? null
              : int.tryParse(_pulseController.text),
        },
        'riskLevel': riskLevel,
        'riskScore': riskScore,
        'riskFactors': riskFactors,
        'recommendations': recommendations,
        'aiReasoning': aiReasoning,
        'aiPowered': !fallbackUsed,
        'recordedBy': 'current_user', // TODO: Get from auth
      });

      // Create prediction record for tracking
      await _firestore.collection('predictions').add({
        'visitId': visitRef.id,
        'patientId': _selectedPatient,
        'riskLevel': riskLevel,
        'riskScore': riskScore,
        'riskFactors': riskFactors,
        'recommendations': recommendations,
        'reasoning': aiReasoning,
        'aiPowered': !fallbackUsed,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update patient last visit
      await _firestore.collection('patients').doc(_selectedPatient).update({
        'lastVisitDate': FieldValue.serverTimestamp(),
        'lastRiskLevel': riskLevel,
        'totalVisits': FieldValue.increment(1),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fallbackUsed
                        ? 'Visit recorded (AI unavailable, using basic risk calculation)'
                        : 'Visit recorded with AI-powered risk assessment!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _calculateRisk() {
    // Simplified risk calculation
    int riskPoints = 0;

    // High fever
    final temp = double.tryParse(_temperatureController.text);
    if (temp != null && temp > 38.5) riskPoints += 2;

    // Symptoms count
    riskPoints += _selectedSymptoms.length;

    // Serious symptoms
    if (_selectedSymptoms.contains('Difficulty breathing')) riskPoints += 3;
    if (_selectedSymptoms.contains('Chest pain')) riskPoints += 3;

    return (riskPoints / 15).clamp(0.0, 1.0);
  }

  String _getRiskLevel(double score) {
    if (score >= 0.7) return 'critical';
    if (score >= 0.5) return 'high';
    if (score >= 0.3) return 'medium';
    return 'low';
  }

  List<String> _getRiskFactors() {
    List<String> factors = [];
    final temp = double.tryParse(_temperatureController.text);
    if (temp != null && temp > 38.5) {
      factors.add('High fever (${temp}°C)');
    }
    if (_selectedSymptoms.contains('Difficulty breathing')) {
      factors.add('Respiratory distress');
    }
    if (_selectedSymptoms.contains('Chest pain')) {
      factors.add('Chest pain present');
    }
    if (_selectedSymptoms.length > 5) {
      factors.add('Multiple symptoms (${_selectedSymptoms.length})');
    }
    return factors;
  }

  List<String> _getRecommendations(String riskLevel) {
    switch (riskLevel) {
      case 'critical':
        return [
          'Immediate referral to higher-level facility',
          'Monitor vital signs every 15 minutes',
          'Ensure IV access and oxygen availability',
        ];
      case 'high':
        return [
          'Close monitoring required',
          'Consider admission or referral',
          'Review in 2-4 hours',
        ];
      case 'medium':
        return [
          'Monitor condition',
          'Prescribe appropriate medication',
          'Review in 24 hours',
        ];
      default:
        return [
          'Continue current treatment',
          'Home care with advice',
          'Return if symptoms worsen',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Record Visit'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.darkText,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Selection
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person, color: AppTheme.darkPurple),
                        SizedBox(width: 12),
                        Text(
                          'Select Patient',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedPatient,
                      decoration: const InputDecoration(
                        hintText: 'Choose patient',
                        prefixIcon: Icon(Icons.search),
                      ),
                      items: _patients.map((patient) {
                        return DropdownMenuItem<String>(
                          value: patient['patientId'] as String,
                          child: Text(
                            '${patient['patientId']} • ${patient['age']}y • ${patient['sex']}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPatient = value);
                      },
                      validator: (value) {
                        if (value == null) return 'Please select a patient';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Vital Signs
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.monitor_heart, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Vital Signs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _temperatureController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Temperature (°C)',
                        hintText: '37.0',
                        prefixIcon: Icon(Icons.thermostat),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bloodPressureController,
                      decoration: const InputDecoration(
                        labelText: 'Blood Pressure',
                        hintText: '120/80',
                        prefixIcon: Icon(Icons.favorite),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pulseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Pulse (bpm)',
                        hintText: '72',
                        prefixIcon: Icon(Icons.favorite_border),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Symptoms
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.sick, color: Colors.orange),
                        SizedBox(width: 12),
                        Text(
                          'Symptoms',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _commonSymptoms.map((symptom) {
                        final isSelected = _selectedSymptoms.contains(symptom);
                        return FilterChip(
                          label: Text(symptom),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSymptoms.add(symptom);
                              } else {
                                _selectedSymptoms.remove(symptom);
                              }
                            });
                          },
                          selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryGreen,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Diagnosis
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.medical_services, color: Colors.blue),
                        SizedBox(width: 12),
                        Text(
                          'Diagnosis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _diagnosisController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Enter diagnosis and treatment plan',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter diagnosis';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _recordVisit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Record Visit & Generate Prediction',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
