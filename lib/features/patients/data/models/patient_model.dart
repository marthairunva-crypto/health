import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health_ai/core/constants/enums.dart';

part 'patient_model.freezed.dart';
part 'patient_model.g.dart';

@freezed
class Patient with _$Patient {
  const factory Patient({
    required String id,
    required String internalCode, // e.g., NSK-000123
    required String sex, // 'M' or 'F'
    required int birthYear,
    required List<ChronicCondition> chronicConditions,
    required String createdBy,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
    @Default(false) bool isSynthetic,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);

  factory Patient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Patient.fromJson({...data, 'id': doc.id});
  }
}

/// Helper for private patient identity (stored in subcollection)
@freezed
class PatientIdentity with _$PatientIdentity {
  const factory PatientIdentity({
    required String fullName,
    String? phoneNumber,
    String? village,
    String? nin, // National Identification Number
  }) = _PatientIdentity;

  factory PatientIdentity.fromJson(Map<String, dynamic> json) =>
      _$PatientIdentityFromJson(json);
}

// Timestamp converters
DateTime _timestampFromJson(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.parse(value);
  }
  return DateTime.now();
}

dynamic _timestampToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
