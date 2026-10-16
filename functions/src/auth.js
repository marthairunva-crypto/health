/**
 * Authentication and user management functions
 */

const {HttpsError} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const {UserRole, COLLECTIONS} = require('./constants');
const {logAudit} = require('./utils/logging');

/**
 * Create a new user account with role (admin only)
 * @param {Object} data - { email, password, displayName, role }
 * @param {Object} context - Auth context
 */
async function createUser(data, context) {
  // Check authentication
  if (!context.auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated');
  }

  // Check admin role
  const callerRole = context.auth.token.role;
  if (callerRole !== UserRole.ADMIN) {
    throw new HttpsError('permission-denied', 'Only admins can create users');
  }

  // Validate input
  const {email, password, displayName, role} = data;

  if (!email || !password || !displayName || !role) {
    throw new HttpsError('invalid-argument', 'Missing required fields');
  }

  if (![UserRole.CLINICIAN, UserRole.ADMIN].includes(role)) {
    throw new HttpsError('invalid-argument', 'Invalid role');
  }

  if (password.length < 8) {
    throw new HttpsError('invalid-argument', 'Password must be at least 8 characters');
  }

  try {
    // Create the user in Firebase Auth
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName,
    });

    // Set custom claims
    await admin.auth().setCustomUserClaims(userRecord.uid, {role});

    // Create user document in Firestore
    const userDoc = {
      email,
      displayName,
      role,
      active: true,
      fcmTokens: [],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLoginAt: null,
    };

    await admin.firestore()
        .collection(COLLECTIONS.USERS)
        .doc(userRecord.uid)
        .set(userDoc);

    // Log audit trail
    await logAudit({
      actorUid: context.auth.uid,
      action: 'user_created',
      targetPath: `users/${userRecord.uid}`,
      metadata: {email, role},
    });

    return {
      success: true,
      uid: userRecord.uid,
      email: userRecord.email,
    };
  } catch (error) {
    console.error('Error creating user:', error);

    if (error.code === 'auth/email-already-exists') {
      throw new HttpsError('already-exists', 'Email already in use');
    }

    throw new HttpsError('internal', 'Failed to create user');
  }
}

module.exports = {
  createUser,
};
