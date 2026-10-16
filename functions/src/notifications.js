/**
 * Notification functions
 */

/**
 * Send FCM notification for high/critical risk predictions
 * @param {Object} event - Firestore event
 */
async function onPredictionCreated(event) {
  // TODO: Implement notification logic
  // 1. Check risk level (high/critical)
  // 2. Query on-duty clinicians
  // 3. Send FCM to their tokens
  console.log('Prediction created trigger - not yet implemented');
}

module.exports = {
  onPredictionCreated,
};
