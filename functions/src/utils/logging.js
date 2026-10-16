/**
 * Logging utilities
 */

const admin = require('firebase-admin');
const {COLLECTIONS} = require('../constants');

/**
 * Log an audit trail entry
 * @param {Object} params - { actorUid, action, targetPath, metadata }
 */
async function logAudit({actorUid, action, targetPath, metadata = {}}) {
  try {
    await admin.firestore()
        .collection(COLLECTIONS.AUDIT_LOGS)
        .add({
          actorUid,
          action,
          targetPath,
          metadata,
          at: admin.firestore.FieldValue.serverTimestamp(),
        });
  } catch (error) {
    console.error('Failed to log audit:', error);
    // Don't throw - logging failure shouldn't break the operation
  }
}

module.exports = {
  logAudit,
};
