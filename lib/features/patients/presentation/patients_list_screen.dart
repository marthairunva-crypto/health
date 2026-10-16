import 'package:flutter/material.dart';
import 'package:health_ai/core/theme/app_theme.dart';
import 'package:health_ai/core/utils/responsive_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterSex = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Patients'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.darkText,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.darkPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: () => Navigator.pushNamed(context, '/new-patient'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID, or age...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.greyText),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
                const SizedBox(height: 12),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Male'),
                      _buildFilterChip('Female'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Patients List
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.getMaxContentWidth(context),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('patients')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error.toString());
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final patients = snapshot.data?.docs ?? [];

                    if (patients.isEmpty) {
                      return _buildEmptyState();
                    }

                    // Filter patients
                    final filteredPatients = patients.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      
                      // Sex filter
                      if (_filterSex != 'All') {
                        final sex = data['sex']?.toString().toLowerCase() ?? '';
                        if (sex != _filterSex.toLowerCase()) return false;
                      }
                      
                      // Search filter
                      if (_searchQuery.isEmpty) return true;
                      final patientId = data['patientId']?.toString().toLowerCase() ?? '';
                      final age = data['age']?.toString() ?? '';
                      final sex = data['sex']?.toString().toLowerCase() ?? '';
                      final name = data['name']?.toString().toLowerCase() ?? '';
                      
                      return patientId.contains(_searchQuery) ||
                          name.contains(_searchQuery) ||
                          age.contains(_searchQuery) ||
                          sex.contains(_searchQuery);
                    }).toList();

                    if (filteredPatients.isEmpty) {
                      return _buildNoResultsState();
                    }

                    return ResponsiveWidget(
                      mobile: _buildMobileList(filteredPatients),
                      tablet: _buildGridView(filteredPatients, 2),
                      desktop: _buildGridView(filteredPatients, 3),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterSex == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _filterSex = label);
        },
        backgroundColor: Colors.grey[100],
        selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
        checkmarkColor: AppTheme.darkPurple,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.darkPurple : AppTheme.greyText,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileList(List<QueryDocumentSnapshot> patients) {
    return ListView.builder(
      padding: ResponsiveUtils.getResponsiveBodyPadding(context),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        final data = patient.data() as Map<String, dynamic>;
        return _PatientCard(
          patientId: data['patientId'] ?? 'Unknown',
          name: data['name'] ?? 'Unknown Patient',
          age: data['age'] ?? 0,
          sex: data['sex'] ?? 'unknown',
          lastVisit: data['lastVisitDate'] != null
              ? (data['lastVisitDate'] as Timestamp).toDate()
              : null,
          riskLevel: data['lastRiskLevel'] ?? 'unknown',
          totalVisits: data['totalVisits'] ?? 0,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/patient-details',
              arguments: patient.id,
            );
          },
        );
      },
    );
  }

  Widget _buildGridView(List<QueryDocumentSnapshot> patients, int crossAxisCount) {
    return GridView.builder(
      padding: ResponsiveUtils.getResponsiveBodyPadding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        final data = patient.data() as Map<String, dynamic>;
        return _PatientCard(
          patientId: data['patientId'] ?? 'Unknown',
          name: data['name'] ?? 'Unknown Patient',
          age: data['age'] ?? 0,
          sex: data['sex'] ?? 'unknown',
          lastVisit: data['lastVisitDate'] != null
              ? (data['lastVisitDate'] as Timestamp).toDate()
              : null,
          riskLevel: data['lastRiskLevel'] ?? 'unknown',
          totalVisits: data['totalVisits'] ?? 0,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/patient-details',
              arguments: patient.id,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 80,
              color: AppTheme.darkPurple.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No patients yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first patient',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.greyText,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/new-patient'),
            icon: const Icon(Icons.add),
            label: const Text('Add First Patient'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkPurple,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.greyText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No patients found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.greyText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final String patientId;
  final String name;
  final int age;
  final String sex;
  final DateTime? lastVisit;
  final String riskLevel;
  final int totalVisits;
  final VoidCallback onTap;

  const _PatientCard({
    required this.patientId,
    required this.name,
    required this.age,
    required this.sex,
    required this.lastVisit,
    required this.riskLevel,
    required this.totalVisits,
    required this.onTap,
  });

  Color _getRiskColor() {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getRiskColor().withOpacity(0.2),
                      _getRiskColor().withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _getRiskColor().withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  sex.toLowerCase() == 'male' ? Icons.male : Icons.female,
                  color: _getRiskColor(),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            patientId,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkPurple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$age yrs • ${sex.capitalize()}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: AppTheme.greyText),
                        const SizedBox(width: 4),
                        Text(
                          lastVisit != null ? _formatDate(lastVisit!) : 'No visits yet',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.greyText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.medical_services, size: 12, color: AppTheme.greyText),
                        const SizedBox(width: 4),
                        Text(
                          '$totalVisits visits',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Risk badge and arrow
              Column(
                children: [
                  if (riskLevel.toLowerCase() != 'unknown')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getRiskColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getRiskColor().withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        riskLevel.capitalize(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getRiskColor(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.greyText,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
