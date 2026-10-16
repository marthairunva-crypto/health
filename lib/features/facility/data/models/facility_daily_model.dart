import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'facility_daily_model.freezed.dart';
part 'facility_daily_model.g.dart';

@freezed
class FacilityDaily with _$FacilityDaily {
  const factory FacilityDaily({
    required String id, // yyyy-MM-dd format
    required int staffOnDuty,
    required int patientLoad,
    @Default([]) List<String> stockouts,
    String? notes,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime date,
    required String updatedBy,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime updatedAt,
  }) = _FacilityDaily;

  factory FacilityDaily.fromJson(Map<String, dynamic> json) =>
      _$FacilityDailyFromJson(json);

  factory FacilityDaily.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FacilityDaily.fromJson({...data, 'id': doc.id});
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

dynamic _timestampToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
