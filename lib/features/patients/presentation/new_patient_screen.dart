import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_ai/core/theme/app_theme.dart';
import 'package:health_ai/core/services/uganda_locations_service.dart';
import 'package:health_ai/core/utils/responsive_utils.dart';
import 'package:health_ai/core/widgets/custom_button.dart';
import 'package:health_ai/core/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

class NewPatientScreen extends StatefulWidget {
  const NewPatientScreen({super.key});

  @override
  State<NewPatientScreen> createState() => _NewPatientScreenState();
}

class _NewPatientScreenState extends State<NewPatientScreen> {
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

  @override
  void initState() {
    super.initState();
    _loadLocationsAsync();
  }

  Future<void> _loadLocationsAsync() async {
    try {
      await _locationService.loadData();
      if (mounted) {
        setState(() {
          _districts = _locationService.getDistricts();
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      print('Error loading locations: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocations = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load location data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final patientId = 'P${timestamp.toString().substring(7)}';

      final address = [
        _selectedVillage,
        _selectedParish,
        _selectedSubCounty,
        '$_selectedDistrict District',
      ].where((e) => e != null && e.isNotEmpty).join(', ');

      await _firestore.collection('patients').add({
        'patientId': patientId,
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
        'createdAt': FieldValue.serverTimestamp(),
        'lastVisitDate': null,
        'lastRiskLevel': 'unknown',
        'totalVisits': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Patient $patientId registered successfully!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('New Patient'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.getMaxContentWidth(context),
              ),
              child: _isLoadingLocations
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading location data...'),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: ResponsiveUtils.getResponsiveBodyPadding(context),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Card
                            _buildHeaderCard(),
                            const SizedBox(height: 24),

                            // Personal Information Section
                            _buildSectionTitle('Personal Information'),
                            const SizedBox(height: 16),
                            _buildPersonalInfoCard(),
                            const SizedBox(height: 24),

                            // Location Section
                            _buildSectionTitle('Location Details'),
                            const SizedBox(height: 16),
                            _buildLocationCard(),
                            const SizedBox(height: 32),

                            // Register Button
                            CustomButton(
                              text: 'Register Patient',
                              icon: Icons.person_add,
                              isLoading: _isLoading,
                              onPressed: _registerPatient,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.person_add_alt_1,
              color: AppTheme.darkPurple,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register New Patient',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Patient ID will be auto-generated',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.greyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.darkPurple,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomTextField(
            label: 'Patient Name',
            hint: 'Enter full name',
            icon: Icons.person_outline,
            controller: _nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter patient name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Age (Years)',
            hint: 'Enter age',
            icon: Icons.cake_outlined,
            controller: _ageController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter age';
              }
              final age = int.tryParse(value);
              if (age == null || age < 0 || age > 150) {
                return 'Please enter a valid age';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sex',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildSexOption('Male', Icons.male),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSexOption('Female', Icons.female),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSexOption(String sex, IconData icon) {
    final isSelected = _sex == sex;
    return InkWell(
      onTap: () => setState(() => _sex = sex),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withOpacity(0.15) : Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey[300]!,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.darkPurple : AppTheme.greyText,
            ),
            const SizedBox(height: 8),
            Text(
              sex,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.darkPurple : AppTheme.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLocationDropdown(
            label: 'District',
            icon: Icons.location_city,
            items: _districts,
            selectedItem: _selectedDistrict,
            onChanged: (value) {
              setState(() {
                _selectedDistrict = value;
                _selectedSubCounty = null;
                _selectedParish = null;
                _selectedVillage = null;
                _subCounties = value != null
                    ? _locationService.getSubCounties(value)
                    : [];
              });
            },
          ),
          const SizedBox(height: 20),
          _buildLocationDropdown(
            label: 'Sub-county',
            icon: Icons.map_outlined,
            items: _subCounties,
            selectedItem: _selectedSubCounty,
            enabled: _selectedDistrict != null,
            onChanged: (value) {
              setState(() {
                _selectedSubCounty = value;
                _selectedParish = null;
                _selectedVillage = null;
                _parishes = (value != null && _selectedDistrict != null)
                    ? _locationService.getParishes(_selectedDistrict!, value)
                    : [];
              });
            },
          ),
          const SizedBox(height: 20),
          _buildLocationDropdown(
            label: 'Parish',
            icon: Icons.location_on_outlined,
            items: _parishes,
            selectedItem: _selectedParish,
            enabled: _selectedSubCounty != null,
            onChanged: (value) {
              setState(() {
                _selectedParish = value;
                _selectedVillage = null;
                _villages = (value != null &&
                        _selectedDistrict != null &&
                        _selectedSubCounty != null)
                    ? _locationService.getVillages(
                        _selectedDistrict!,
                        _selectedSubCounty!,
                        value,
                      )
                    : [];
              });
            },
          ),
          const SizedBox(height: 20),
          _buildLocationDropdown(
            label: 'Village',
            icon: Icons.home_outlined,
            items: _villages,
            selectedItem: _selectedVillage,
            enabled: _selectedParish != null,
            onChanged: (value) {
              setState(() => _selectedVillage = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? selectedItem,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownSearch<String>(
          items: (filter, infiniteScrollProps) => items,
          selectedItem: selectedItem,
          enabled: enabled,
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Type to search ${label.toLowerCase()}...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            menuProps: MenuProps(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            constraints: const BoxConstraints(maxHeight: 350),
          ),
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: TextStyle(
                color: AppTheme.greyText.withOpacity(0.6),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                icon,
                color: enabled
                    ? AppTheme.darkPurple.withOpacity(0.7)
                    : AppTheme.greyText.withOpacity(0.5),
                size: 22,
              ),
              filled: true,
              fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
              ),
            ),
          ),
          onBeforeChange: (prev, next) async {
            onChanged(next);
            return true;
          },
          validator: (value) => value == null ? 'Please select $label' : null,
        ),
      ],
    );
  }
}
