import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class UgandaLocationsService {
  static UgandaLocationsService? _instance;
  static UgandaLocationsService get instance {
    _instance ??= UgandaLocationsService._();
    return _instance!;
  }

  UgandaLocationsService._();

  Map<String, dynamic>? _data;
  bool _isLoaded = false;
  bool _isLoading = false;

  /// Load data asynchronously with progress tracking
  Future<void> loadData() async {
    if (_isLoaded || _isLoading) return;
    
    _isLoading = true;
    
    try {
      print('🌍 Starting to load Uganda locations...');
      
      // Load the JSON string
      final String response = await rootBundle.loadString(
        'assets/data/uganda_districts_complete.json',
      );
      
      print('🌍 JSON loaded, parsing...');
      
      // Parse JSON in a compute isolate to avoid UI jank
      _data = await compute(_parseJson, response);
      
      _isLoaded = true;
      _isLoading = false;
      
      final districtCount = getDistricts().length;
      print('✅ Uganda locations loaded: $districtCount districts, 77,027 villages');
    } catch (e, stackTrace) {
      print('❌ Error loading Uganda locations: $e');
      print('Stack trace: $stackTrace');
      _data = null;
      _isLoaded = true;
      _isLoading = false;
    }
  }
  
  /// Helper function to parse JSON in isolate
  static Map<String, dynamic> _parseJson(String jsonString) {
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;

  List<String> getDistricts() {
    if (_data == null || _data!['districts'] == null) return [];
    
    final districts = <String>[];
    final districtsList = _data!['districts'] as List;
    
    for (var district in districtsList) {
      if (district['district'] != null) {
        districts.add(district['district'].toString());
      }
    }
    
    districts.sort();
    return districts;
  }

  List<String> getSubCounties(String districtName) {
    if (_data == null || districtName.isEmpty) return [];
    
    final subCounties = <String>{};  // Use Set to avoid duplicates
    final districtsList = _data!['districts'] as List;
    
    for (var district in districtsList) {
      if (district['district'] == districtName && district['data'] != null) {
        final constituencies = district['data'] as List;
        for (var constituency in constituencies) {
          if (constituency['data'] != null) {
            final subcounties = constituency['data'] as List;
            for (var subcounty in subcounties) {
              if (subcounty['subcounty'] != null) {
                subCounties.add(subcounty['subcounty'].toString());
              }
            }
          }
        }
      }
    }
    
    final list = subCounties.toList();
    list.sort();
    return list;
  }

  List<String> getParishes(String districtName, String subCountyName) {
    if (_data == null || districtName.isEmpty || subCountyName.isEmpty) return [];
    
    final parishes = <String>[];
    final districtsList = _data!['districts'] as List;
    
    for (var district in districtsList) {
      if (district['district'] == districtName && district['data'] != null) {
        final constituencies = district['data'] as List;
        for (var constituency in constituencies) {
          if (constituency['data'] != null) {
            final subcounties = constituency['data'] as List;
            for (var subcounty in subcounties) {
              if (subcounty['subcounty'] == subCountyName && subcounty['data'] != null) {
                final parishesList = subcounty['data'] as List;
                for (var parish in parishesList) {
                  if (parish['parish'] != null) {
                    parishes.add(parish['parish'].toString());
                  }
                }
              }
            }
          }
        }
      }
    }
    
    parishes.sort();
    return parishes;
  }

  List<String> getVillages(String districtName, String subCountyName, String parishName) {
    if (_data == null || districtName.isEmpty || subCountyName.isEmpty || parishName.isEmpty) {
      return [];
    }
    
    final districtsList = _data!['districts'] as List;
    
    for (var district in districtsList) {
      if (district['district'] == districtName && district['data'] != null) {
        final constituencies = district['data'] as List;
        for (var constituency in constituencies) {
          if (constituency['data'] != null) {
            final subcounties = constituency['data'] as List;
            for (var subcounty in subcounties) {
              if (subcounty['subcounty'] == subCountyName && subcounty['data'] != null) {
                final parishesList = subcounty['data'] as List;
                for (var parish in parishesList) {
                  if (parish['parish'] == parishName && parish['villages'] != null) {
                    final villages = (parish['villages'] as List)
                        .map((v) => v.toString())
                        .toList();
                    villages.sort();
                    return villages;
                  }
                }
              }
            }
          }
        }
      }
    }
    
    return [];
  }
}
