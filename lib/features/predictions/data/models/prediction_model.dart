import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health_ai/core/constants/enums.dart';

part 'prediction_model.freezed.dart';
part 'prediction_model.g.dart';

@freezed
class Prediction with _$Prediction {
  const factory Prediction({
    required String id,
    required String visitId,
    required String patientId,
    required RiskLevel riskLevel,
    required int riskScore, // 0-100
    required List<ConsequenceProbability> consequences,
    required List<RiskFactor> topFactors,
    required List<String> recommendations,
    @Default([]) List<String> missingData,
    required PredictionSource source, // 'groq' or 'baseline'
    required PredictionConfidence confidence,
    String? modelVersion,
    String? promptVersion,
    @Default(false) bool needsClinicianReview,
    PredictionFeedback? feedback,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
  }) = _Prediction;

  factory Prediction.fromJson(Map<String, dynamic> json) =>
      _$PredictionFromJson(json);

  factory Prediction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Prediction.fromJson({...data, 'id': doc.id});
  }
}

@freezed
class ConsequenceProbability with _$ConsequenceProbability {
  const factory ConsequenceProbability({
    required ConsequenceType type,
    required double probability, // 0.0 to 1.0
  }) = _ConsequenceProbability;

  factory ConsequenceProbability.fromJson(Map<String, dynamic> json) =>
      _$ConsequenceProbabilityFromJson(json);
}

@freezed
class RiskFactor with _$RiskFactor {
  const factory RiskFactor({
    required String factor,
    required String direction, // 'increases' or 'decreases'
    required String explanation, // max 25 words
  }) = _RiskFactor;

  factory RiskFactor.fromJson(Map<String, dynamic> json) =>
      _$RiskFactorFromJson(json);
}

@freezed
class PredictionFeedback with _$PredictionFeedback {
  const factory PredictionFeedback({
    required bool agreed,
    String? comment,
    required String by,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime at,
  }) = _PredictionFeedback;

  factory PredictionFeedback.fromJson(Map<String, dynamic> json) =>
      _$PredictionFeedbackFromJson(json);
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
