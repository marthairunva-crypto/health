/**
 * Cloud Functions for Nsiika Health Centre IV Prediction App
 * Region: europe-west1
 * Runtime: Node.js 20
 */

const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {onDocumentWritten, onDocumentCreated} = require('firebase-functions/v2/firestore');
const {defineSecret} = require('firebase-functions/params');
const admin = require('firebase-admin');

// Load environment variables for local development
if (process.env.FUNCTIONS_EMULATOR === 'true') {
  require('dotenv').config({path: '.env.local'});
}

// Initialize Firebase Admin
admin.initializeApp();

// Define secrets (in production) or load from env (in emulator)
const GROQ_API_KEY = process.env.FUNCTIONS_EMULATOR === 'true' 
  ? {value: () => process.env.GROQ_API_KEY}
  : defineSecret('GROQ_API_KEY');

// Import function modules
const {createUser} = require('./src/auth');
const {predictRisk} = require('./src/predictions');
const {onVisitWritten} = require('./src/triggers');
const {onPredictionCreated} = require('./src/notifications');
const {exportValidationData} = require('./src/exports');

// Export functions
exports.createUser = onCall({region: 'europe-west1'}, createUser);

exports.predictRisk = onCall({
  region: 'europe-west1',
  secrets: [GROQ_API_KEY],
  timeoutSeconds: 60,
  memory: '512MiB',
}, predictRisk);

exports.onVisitWritten = onDocumentWritten({
  region: 'europe-west1',
  document: 'visits/{visitId}',
  secrets: [GROQ_API_KEY],
}, onVisitWritten);

exports.onPredictionCreated = onDocumentCreated({
  region: 'europe-west1',
  document: 'predictions/{predictionId}',
}, onPredictionCreated);

exports.exportValidationData = onCall({
  region: 'europe-west1',
}, exportValidationData);
