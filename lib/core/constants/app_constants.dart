/// Application-wide constants
library;

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Nsiika HC IV';
  static const String appVersion = '1.0.0';

  // Firebase
  static const String firebaseRegion = 'europe-west1';
  static const int functionTimeoutSeconds = 30;

  // Firestore collections
  static const String usersCollection = 'users';
  static const String patientsCollection = 'patients';
  static const String visitsCollection = 'visits';
  static const String predictionsCollection = 'predictions';
  static const String facilityDailyCollection = 'facilityDaily';
  static const String auditLogsCollection = 'auditLogs';

  // Subcollections
  static const String patientPrivateSubcollection = 'private';
  static const String identityDocument = 'identity';

  // Clinical validation ranges
  static const double minTemperatureC = 30.0;
  static const double maxTemperatureC = 45.0;
  static const int minPulseBpm = 20;
  static const int maxPulseBpm = 250;
  static const int minRespRate = 5;
  static const int maxRespRate = 80;
  static const int minSystolicBp = 40;
  static const int maxSystolicBp = 250;
  static const int minDiastolicBp = 20;
  static const int maxDiastolicBp = 180;
  static const int minSpo2Pct = 50;
  static const int maxSpo2Pct = 100;
  static const double minWeightKg = 0.5;
  static const double maxWeightKg = 300.0;
  static const int minMuacMm = 50;
  static const int maxMuacMm = 250;

  // Risk thresholds
  static const int lowRiskThreshold = 25;
  static const int moderateRiskThreshold = 50;
  static const int highRiskThreshold = 75;

  // Rate limiting
  static const int maxPredictionsPerUserPerHour = 30;

  // Offline sync
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 5;

  // UI
  static const double minTouchTargetSize = 48.0;
  static const int maxPresentingComplaintLength = 300;
  
  // Decision support disclaimer
  static const String decisionSupportDisclaimer = 
      'Decision-support only. Does not replace clinical judgement.';

  // Cache
  static const int predictionCacheMinutes = 10;
}
