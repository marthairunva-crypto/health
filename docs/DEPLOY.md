# Deployment Guide

## Prerequisites

### Required Tools
- Flutter SDK (3.12.2 or later)
- Firebase CLI (`npm install -g firebase-tools`)
- Node.js 20 (for Cloud Functions)
- Android Studio (for APK builds)

### Firebase Setup
- Firebase project: `my-first-project-e8a6e`
- Billing enabled (Blaze plan required for Cloud Functions)
- Budget alert recommended: USD 5

## Initial Setup

### 1. Firebase Project Configuration

Your project is already configured with:
- Project ID: `my-first-project-e8a6e`
- Region: `europe-west1` (for functions)
- `google-services.json` already in place

### 2. Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### 3. Initialize Firebase in Project

```bash
# In project root
firebase use my-first-project-e8a6e
```

### 4. Set Groq API Key Secret

**IMPORTANT**: Never commit the API key to git!

```bash
# Set the secret (you'll be prompted to enter the key)
firebase functions:secrets:set GROQ_API_KEY
```

Get your Groq API key from: https://console.groq.com/keys

### 5. Install Flutter Dependencies

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. Install Functions Dependencies

```bash
cd functions
npm install
cd ..
```

## Development with Emulators

### Start Firebase Emulators

```bash
firebase emulators:start
```

This starts:
- Auth emulator: http://localhost:9099
- Firestore emulator: http://localhost:8080
- Functions emulator: http://localhost:5001
- Emulator UI: http://localhost:4000

### Configure Flutter to Use Emulators

In development mode, connect to emulators (see `lib/core/firebase/firebase_config.dart`)

### Run Flutter App

```bash
flutter run
```

## Testing

### Run Dart Tests

```bash
flutter test
```

### Run Functions Tests

```bash
cd functions
npm test
cd ..
```

### Test Firestore Rules

```bash
firebase emulators:exec --only firestore "cd test && npm test"
```

## Deployment

### 1. Deploy Firestore Rules and Indexes

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

### 2. Deploy Cloud Functions

```bash
firebase deploy --only functions
```

**Note**: First deployment may take 5-10 minutes.

### 3. Verify Functions are Live

```bash
firebase functions:list
```

Expected functions:
- createUser
- predictRisk
- onVisitWritten
- onPredictionCreated
- exportValidationData

### 4. Build Flutter Release APK

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

### 5. Create Initial Admin Account

Use Firebase Console to:
1. Go to Authentication → Users
2. Add user manually with email/password
3. Set custom claims in Firestore:

```javascript
// In Firebase Console > Firestore
// Create document in 'users' collection:
{
  uid: "<user-uid>",
  email: "admin@nsiika.org",
  displayName: "Admin User",
  role: "admin",
  active: true,
  fcmTokens: [],
  createdAt: <timestamp>
}
```

Then set custom claims via Functions or Firebase CLI:

```bash
firebase functions:shell
# Then in shell:
# admin.auth().setCustomUserClaims('USER_UID', { role: 'admin' })
```

## Production Checklist

- [ ] Groq API key set as secret
- [ ] Firebase Blaze plan enabled
- [ ] Budget alert configured
- [ ] Firestore rules deployed
- [ ] Firestore indexes deployed
- [ ] All functions deployed successfully
- [ ] At least one admin account created
- [ ] Release APK built and tested on device
- [ ] No secrets in git (`git grep -i groq` returns nothing)
- [ ] `.gitignore` covers sensitive files

## Monitoring

### View Function Logs

```bash
firebase functions:log
```

### View Crashlytics (after first app use)

Firebase Console → Crashlytics

### Check Firestore Usage

Firebase Console → Firestore Database → Usage tab

## Rollback

### Rollback Functions

```bash
# List deployments
firebase functions:list

# Delete specific function
firebase functions:delete FUNCTION_NAME
```

### Rollback Rules

Deploy previous version from git:
```bash
git checkout PREVIOUS_COMMIT -- firestore.rules
firebase deploy --only firestore:rules
```

## Cost Estimates

### Expected Monthly Cost (Development/Small Deployment)
- Firestore: Free tier (50K reads, 20K writes, 20K deletes per day)
- Functions: Free tier (2M invocations, 400K GB-sec, 200K CPU-sec)
- Auth: Free
- **Groq API**: Check current pricing at https://groq.com/pricing

**Estimated**: $0-5 USD/month for development and small pilot

### Set Budget Alert

Firebase Console → Billing → Budgets & Alerts → Create Budget
