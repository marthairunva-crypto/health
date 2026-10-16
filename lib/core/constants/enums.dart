/// Core enums for the Nsiika Health Centre IV Prediction App
/// Keep these identical to the JavaScript versions in functions/src/constants.js
library;

enum ConsequenceType {
  complication,
  delayedTreatment,
  readmission30d,
  clinicalDeterioration,
  preventableDeathRisk,
}

enum RiskLevel {
  low,
  moderate,
  high,
  critical,
}

enum UserRole {
  clinician,
  admin,
}

enum TriageCategory {
  emergency,
  urgent,
  routine,
}

enum ReferralType {
  none,
  inPatient,  // in
  outPatient, // out
}

enum Shift {
  day,
  night,
  weekend,
}

enum PredictionSource {
  groq,
  baseline,
}

enum PredictionConfidence {
  low,
  medium,
  high,
}

enum PredictionStatus {
  pending,
  completed,
  failed,
}

// Chronic conditions
enum ChronicCondition {
  hiv,
  hypertension,
  diabetes,
  tb,
  sickleCell,
  malnutrition,
  other,
}

// Extensions for enum string conversion
extension ConsequenceTypeExtension on ConsequenceType {
  String toShortString() {
    return toString().split('.').last;
  }

  static ConsequenceType fromString(String value) {
    return ConsequenceType.values.firstWhere(
      (e) => e.toShortString() == value,
      orElse: () => ConsequenceType.complication,
    );
  }
}

extension RiskLevelExtension on RiskLevel {
  String toShortString() {
    return toString().split('.').last;
  }

  static RiskLevel fromString(String value) {
    return RiskLevel.values.firstWhere(
      (e) => e.toShortString() == value,
      orElse: () => RiskLevel.low,
    );
  }

  static RiskLevel fromScore(int score) {
    if (score < 25) return RiskLevel.low;
    if (score < 50) return RiskLevel.moderate;
    if (score < 75) return RiskLevel.high;
    return RiskLevel.critical;
  }
}

extension UserRoleExtension on UserRole {
  String toShortString() {
    return toString().split('.').last;
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.toShortString() == value,
      orElse: () => UserRole.clinician,
    );
  }
}
