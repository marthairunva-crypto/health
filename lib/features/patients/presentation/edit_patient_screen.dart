import 'package:flutter/material.dart';
import 'package:health_ai/core/theme/app_theme.dart';
import 'package:health_ai/core/services/uganda_locations_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

class EditPatientScreen extends StatefulWidget {
  const EditPatientScreen({super.key});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _locationService = UgandaLocationsService.instance;

  String _sex = 'Male';
  bool _isLoading = false;
  bool _isLoadingLocations = true;

  String? _selectedDistrict;
  String? _selectedSubCounty;
  String? _selectedParish;
  String? _selectedVillage;

  List<String> _districts = [];
  List<String> _subCounties = [];
  List<String> _parishes = [];
  List<String> _villages = [];

  late String _docId;
  late Map<String, dynamic> _initialData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _docId = args['docId'] as String;
    _initialData = args['data'] as Map<String, dynamic>;
    _initializeData();
  }

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  void _initializeData() {
    _nameController.text = _initialData['name'] ?? '';
    _ageController.text = _initialData['age']?.toString() ?? '';
    _sex = _initialData['sex']?.toString().capitalize() ?? 'Male';
    
    // Initialize location if available
    if (_initialData['location'] != null) {
      final location = _initialData['location'] as Map<String, dynamic>;
      _selectedDistrict = location['district'];
      _selectedSubCounty = location['subCounty'];
      _selectedParish = location['parish'];
      _selectedVillage = location['village'];
    }
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoadingLocations = true);
    await _locationService.loadData();
    setState(() {
      _districts = _locationService.getDistricts();
      if (_selectedDistrict != null) {
        _subCounties = _locationService.getSubCounties(_selectedDistrict!);
        if (_selectedSubCounty != null) {
          _parishes = _locationService.getParishes(_selectedDistrict!, _selectedSubCounty!);
          if (_selectedParish != null) {
            _villages = _locationService.getVillages(
              _selectedDistrict!,
              _selectedSubCounty!,
              _selectedParish!,
            );
          }
        }
      }
      _isLoadingLocations = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _updatePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Build address
      final address = [
        _selectedVillage,
        _selectedParish,
        _selectedSubCounty,
        '$_selectedDistrict District',
      ].where((e) => e != null && e.isNotEmpty).join(', ');

      // Update patient document
      await _firestore.collection('patients').doc(_docId).update({
        'name': _nameController.text.trim(),
        'age': int.parse(_ageController.text),
        'sex': _sex.toLowerCase(),
        'address': address,
        'location': {
          'district': _selectedDistrict,
          'subCounty': _selectedSubCounty,
          'parish': _selectedParish,
          'village': _selectedVillage,
        },
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient updated successfully!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit Patient'),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreen.withOpacity(0.1),
                      AppTheme.primaryPurple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: AppTheme.primaryGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Update Patient Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Patient ${_initialData['patientId']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
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
                    // Name
                    const Text(
                      'Patient Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Enter patient full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter patient name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Age
                    const Text(
                      'Age (Years)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter patient age',
                        prefixIcon: Icon(Icons.cake),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter age';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 0 || age > 120) {
                          return 'Please enter valid age (0-120)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Sex
                    const Text(
                      'Sex',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SexOption(
                            label: 'Male',
                            icon: Icons.male,
                            isSelected: _sex == 'Male',
                            onTap: () => setState(() => _sex = 'Male'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SexOption(
                            label: 'Female',
                            icon: Icons.female,
                            isSelected: _sex == 'Female',
                            onTap: () => setState(() => _sex = 'Female'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePatient,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
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

class _SexOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SexOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? AppTheme.primaryGreen : AppTheme.greyText,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryGreen : AppTheme.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
