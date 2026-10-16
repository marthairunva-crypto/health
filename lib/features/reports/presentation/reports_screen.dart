import 'package:flutter/material.dart';
import 'package:health_ai/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _firestore = FirebaseFirestore.instance;
  String _selectedPeriod = 'week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.darkText,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _PeriodButton(
                    label: 'Today',
                    isSelected: _selectedPeriod == 'today',
                    onTap: () => setState(() => _selectedPeriod = 'today'),
                  ),
                  _PeriodButton(
                    label: 'Week',
                    isSelected: _selectedPeriod == 'week',
                    onTap: () => setState(() => _selectedPeriod = 'week'),
                  ),
                  _PeriodButton(
                    label: 'Month',
                    isSelected: _selectedPeriod == 'month',
                    onTap: () => setState(() => _selectedPeriod = 'month'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Summary Stats
            FutureBuilder<Map<String, dynamic>>(
              future: _getStats(_selectedPeriod),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final stats = snapshot.data ?? {};

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          icon: Icons.people,
                          label: 'Total Patients',
                          value: stats['totalPatients']?.toString() ?? '0',
                          color: AppTheme.darkPurple,
                        ),
                        _StatCard(
                          icon: Icons.medical_services,
                          label: 'Total Visits',
                          value: stats['totalVisits']?.toString() ?? '0',
                          color: Colors.blue,
                        ),
                        _StatCard(
                          icon: Icons.warning,
                          label: 'High Risk',
                          value: stats['highRisk']?.toString() ?? '0',
                          color: Colors.orange,
                        ),
                        _StatCard(
                          icon: Icons.check_circle,
                          label: 'Low Risk',
                          value: stats['lowRisk']?.toString() ?? '0',
                          color: Colors.green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Risk Distribution
                    const Text(
                      'Risk Distribution',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        children: [
                          _RiskBar(
                            label: 'Critical',
                            count: stats['critical'] ?? 0,
                            total: stats['totalVisits'] ?? 1,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          _RiskBar(
                            label: 'High',
                            count: stats['highRisk'] ?? 0,
                            total: stats['totalVisits'] ?? 1,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          _RiskBar(
                            label: 'Medium',
                            count: stats['medium'] ?? 0,
                            total: stats['totalVisits'] ?? 1,
                            color: Colors.amber,
                          ),
                          const SizedBox(height: 16),
                          _RiskBar(
                            label: 'Low',
                            count: stats['lowRisk'] ?? 0,
                            total: stats['totalVisits'] ?? 1,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Common Diagnoses
                    const Text(
                      'Top Diagnoses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('visits')
                          .orderBy('visitDate', descending: true)
                          .limit(50)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text('No data available'),
                            ),
                          );
                        }

                        // Count diagnoses
                        final diagnosisCount = <String, int>{};
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final diagnosis = data['diagnosis'] ?? 'Unknown';
                          diagnosisCount[diagnosis] =
                              (diagnosisCount[diagnosis] ?? 0) + 1;
                        }

                        // Sort by count
                        final sortedDiagnoses = diagnosisCount.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));

                        return Container(
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
                            children: sortedDiagnoses.take(5).map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.darkText,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreen
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        entry.value.toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getStats(String period) async {
    try {
      DateTime startDate;
      final now = DateTime.now();

      switch (period) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      // Get visits
      final visitsSnap = await _firestore
          .collection('visits')
          .where('visitDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      // Get patients
      final patientsSnap = await _firestore.collection('patients').get();

      // Calculate risk counts
      int critical = 0;
      int highRisk = 0;
      int medium = 0;
      int lowRisk = 0;

      for (var doc in visitsSnap.docs) {
        final data = doc.data();
        final risk = data['riskLevel']?.toString().toLowerCase() ?? '';
        switch (risk) {
          case 'critical':
            critical++;
            break;
          case 'high':
            highRisk++;
            break;
          case 'medium':
            medium++;
            break;
          case 'low':
            lowRisk++;
            break;
        }
      }

      return {
        'totalPatients': patientsSnap.docs.length,
        'totalVisits': visitsSnap.docs.length,
        'critical': critical,
        'highRisk': highRisk,
        'medium': medium,
        'lowRisk': lowRisk,
      };
    } catch (e) {
      return {
        'totalPatients': 0,
        'totalVisits': 0,
        'critical': 0,
        'highRisk': 0,
        'medium': 0,
        'lowRisk': 0,
      };
    }
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.darkPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.greyText,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.greyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _RiskBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
            Text(
              '$count ($percentage%)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? count / total : 0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
