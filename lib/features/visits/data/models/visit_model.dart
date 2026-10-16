import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health_ai/core/constants/enums.dart';

part 'visit_model.freezed.dart';
part 'visit_model.g.dart';

@freezed
class Visit with _$Visit {
  const factory Visit({
    required String id,
    required String patientId,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime visitDate,
    
    // Clinical data
    required String presentingComplaint,
    String? suspectedDiagnosis,
    double? temperatureC,
    int? pulseBpm,
    int? respRate,
    int? systolicBp,
    int? diastolicBp,
    int? spo2Pct,
    double? weightKg,
    int? muacMm, // for children
    required TriageCategory triageCategory,
    required ReferralType referralType,
    int? symptomDurationDays,
    
    // Health-system factors
    int? waitTimeMinutes,
    int? referralDelayHours,
    int? staffOnDuty,
    int? patientLoadToday,
    @Default([]) List<String> medicinesPrescribed,
    @Default([]) List<String> medicinesOutOfStock,
    @Default(false) bool labAvailable,
    @Default(false) bool ambulanceAvailable,
    required Shift shift,
    
    // Ground truth (filled later for validation)
    @Default([]) List<ConsequenceType> actualOutcome,
    @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable)
    DateTime? outcomeRecordedAt,
    String? outcomeRecordedBy,
    
    // Metadata
    required String createdBy,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime updatedAt,
    @Default(false) bool isSynthetic,
    
    // Prediction status for offline sync
    @Default(PredictionStatus.pending) PredictionStatus predictionStatus,
  }) = _Visit;

  factory Visit.fromJson(Map<String, dynamic> json) =>
      _$VisitFromJson(json);

  factory Visit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Visit.fromJson({...data, 'id': doc.id});
  }
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

DateTime? _timestampFromJsonNullable(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.parse(value);
  }
  return null;
}

dynamic _timestampToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);

dynamic _timestampToJsonNullable(DateTime? dateTime) =>
    dateTime != null ? Timestamp.fromDate(dateTime) : null;
