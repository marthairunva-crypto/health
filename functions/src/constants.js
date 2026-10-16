/**
 * Constants shared across Cloud Functions
 * Keep these in sync with Dart enums in lib/core/constants/enums.dart
 */

const ConsequenceType = {
  COMPLICATION: 'complication',
  DELAYED_TREATMENT: 'delayedTreatment',
  READMISSION_30D: 'readmission30d',
  CLINICAL_DETERIORATION: 'clinicalDeterioration',
  PREVENTABLE_DEATH_RISK: 'preventableDeathRisk',
};

const RiskLevel = {
  LOW: 'low',
  MODERATE: 'moderate',
  HIGH: 'high',
  CRITICAL: 'critical',
};

const UserRole = {
  CLINICIAN: 'clinician',
  ADMIN: 'admin',
};

const PredictionSource = {
  GROQ: 'groq',
  BASELINE: 'baseline',
};

const PredictionConfidence = {
  LOW: 'low',
  MEDIUM: 'medium',
  HIGH: 'high',
};

// Firebase
const FIREBASE_REGION = 'europe-west1';
const COLLECTIONS = {
  USERS: 'users',
  PATIENTS: 'patients',
  VISITS: 'visits',
  PREDICTIONS: 'predictions',
  FACILITY_DAILY: 'facilityDaily',
  AUDIT_LOGS: 'auditLogs',
};

// Risk thresholds
const RISK_THRESHOLDS = {
  LOW: 25,
  MODERATE: 50,
  HIGH: 75,
};

// Groq API
const GROQ_API_URL = 'https://api.groq.com/openai/v1/chat/completions';
// Updated from https://console.groq.com/docs/models (verified 2026-10-11)
// Options: 
//   - llama-3.3-70b-versatile (560 tps, Enterprise, best for complex reasoning)
//   - llama-3.1-70b-versatile (280 tps, Enterprise, stable)
//   - GPT-OSS 120B (500 tps, paid $0.15/1M, high performance)
//   - GPT-OSS 20B (1000 tps, paid $0.075/1M, fast inference)
const GROQ_MODEL = 'llama-3.3-70b-versatile'; // Best balance: speed + reasoning + free
const GROQ_TEMPERATURE = 0.1;
const GROQ_MAX_TOKENS = 800;
const GROQ_TIMEOUT_MS = 20000;

// Prediction settings
const MAX_PREDICTIONS_PER_USER_PER_HOUR = 30;
const PREDICTION_CACHE_MINUTES = 10;
const PROMPT_VERSION = 'v1';

module.exports = {
  ConsequenceType,
  RiskLevel,
  UserRole,
  PredictionSource,
  PredictionConfidence,
  FIREBASE_REGION,
  COLLECTIONS,
  RISK_THRESHOLDS,
  GROQ_API_URL,
  GROQ_MODEL,
  GROQ_TEMPERATURE,
  GROQ_MAX_TOKENS,
  GROQ_TIMEOUT_MS,
  MAX_PREDICTIONS_PER_USER_PER_HOUR,
  PREDICTION_CACHE_MINUTES,
  PROMPT_VERSION,
};
