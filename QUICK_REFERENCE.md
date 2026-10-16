# 🚀 Quick Reference Card

## Essential Commands

### Development
```bash
# Install dependencies
flutter pub get
cd functions && npm install && cd ..

# Generate code after model changes
flutter pub run build_runner build --delete-conflicting-outputs

# Start Firebase emulators
firebase emulators:start

# Run Flutter app
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test
cd functions && npm test && cd ..
```

### Deployment
```bash
# Set Groq API key (one time)
firebase functions:secrets:set GROQ_API_KEY

# Deploy everything
firebase deploy

# Deploy specific targets
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only functions
```

## Project Configuration

### Firebase Project
- **ID**: `my-first-project-e8a6e`
- **Region**: `europe-west1`
- **Emulator UI**: http://localhost:4000

### Groq AI
- **Model**: `llama-3.3-70b-versatile`
- **Console**: https://console.groq.com
- **Docs**: https://console.groq.com/docs

## Key File Locations

### Data Models
```
lib/features/patients/data/models/patient_model.dart
lib/features/visits/data/models/visit_model.dart
lib/features/predictions/data/models/prediction_model.dart
lib/features/auth/data/user_model.dart
lib/features/facility/data/models/facility_daily_model.dart
```

### Cloud Functions
```
functions/index.js                 # Function exports
functions/src/constants.js         # Configuration
functions/src/auth.js              # User management (✅ complete)
functions/src/predictions.js       # Risk prediction (🚧 stub)
```

### Configuration
```
firebase.json                      # Firebase & emulator config
firestore.rules                    # Security rules
firestore.indexes.json             # Query indexes
pubspec.yaml                       # Flutter dependencies
functions/package.json             # Node dependencies
```

### Documentation
```
README.md                          # Project overview
docs/ARCHITECTURE.md               # System design
docs/DEPLOY.md                     # Deployment guide
docs/ASSUMPTIONS.md                # Clinical assumptions
docs/GROQ_MODELS.md                # AI model guide
NEXT_STEPS.md                      # Implementation roadmap
PROJECT_STRUCTURE.md               # File organization
```

## Core Enums (Dart ↔ JavaScript)

### ConsequenceType
- `complication`
- `delayedTreatment`
- `readmission30d`
- `clinicalDeterioration`
- `preventableDeathRisk`

### RiskLevel
- `low` (0-24)
- `moderate` (25-49)
- `high` (50-74)
- `critical` (75-100)

### UserRole
- `clinician`
- `admin`

### TriageCategory
- `emergency`
- `urgent`
- `routine`

## Firestore Collections

```
users/{uid}                        # User accounts
patients/{id}                      # Patient records
  └─ private/{doc}                 # PII subcollection
visits/{id}                        # Visit records
predictions/{id}                   # Risk predictions
facilityDaily/{yyyy-MM-dd}        # Daily facility status
auditLogs/{id}                    # Audit trail
```

## Security Rules Summary

```javascript
// Users
users/{uid}
  read: if signedIn && (isOwner || isAdmin)
  write: false (functions only)

// Patients  
patients/{id}
  read, create, update: if isStaff
  delete: if isAdmin
  
// Visits
visits/{id}
  read, create, update: if isStaff
  delete: if isAdmin
  
// Predictions
predictions/{id}
  read: if isStaff
  create, delete: false (functions only)
  update: if isStaff && onlyChangingFeedback
  
// Audit logs
auditLogs/{id}
  read: if isAdmin
  write: false (functions only)
```

## Environment Setup

### Emulator Ports
- Auth: 9099
- Firestore: 8080
- Functions: 5001
- UI: 4000

### Development URLs
- Emulator UI: http://localhost:4000
- Functions: http://localhost:5001/my-first-project-e8a6e/europe-west1/{functionName}

## Common Issues & Solutions

### Issue: Build runner fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Emulators won't start
```bash
# Kill existing processes
npx kill-port 4000 5001 8080 9099
# Restart
firebase emulators:start
```

### Issue: Hot reload not working
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Or restart: `flutter run`

### Issue: Functions not deploying
```bash
# Check you're in the right project
firebase use my-first-project-e8a6e
# Redeploy
firebase deploy --only functions --force
```

### Issue: Can't find generated files
Generated files (*.g.dart, *.freezed.dart) are excluded from git. Run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing Checklist

### Before Committing
- [ ] `flutter analyze` passes (or only Freezed warnings)
- [ ] Code formatted: `flutter format .`
- [ ] Tests pass: `flutter test`
- [ ] Functions test: `cd functions && npm test`
- [ ] CHANGELOG.md updated

### Before Deploying
- [ ] Tested in emulators
- [ ] Groq API key set
- [ ] No secrets in code
- [ ] Security rules tested
- [ ] Documentation updated

## Git Workflow

```bash
# Check status
git status

# Stage changes
git add .

# Commit (use conventional commits)
git commit -m "feat: implement authentication flow"
git commit -m "fix: resolve offline sync issue"
git commit -m "docs: update deployment guide"

# Push
git push
```

### Conventional Commit Types
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` Code formatting
- `refactor:` Code restructuring
- `test:` Adding tests
- `chore:` Maintenance

## Decision Support Disclaimer

**Always display:**
> Decision-support only. Does not replace clinical judgement.

**In code:**
```dart
AppConstants.decisionSupportDisclaimer
```

## Contact & Resources

### Project Team
- Student: [Your name]
- Supervisor: [Supervisor name]
- Institution: Metropolitan International University
- Facility: Nsiika Health Centre IV

### Key Resources
- Flutter: https://flutter.dev
- Firebase: https://firebase.google.com/docs
- Riverpod: https://riverpod.dev
- Groq: https://console.groq.com/docs
- Material 3: https://m3.material.io

### Support
- Project docs: `docs/` folder
- Flutter Discord: https://discord.gg/flutter
- Stack Overflow: Tag `flutter`, `firebase`, `dart`

---

## Next Phase: Authentication

**Files to create:**
1. `lib/core/firebase/firebase_config.dart`
2. `lib/features/auth/data/auth_repository.dart`
3. `lib/features/auth/presentation/login_screen.dart`
4. `lib/core/router/app_router.dart`

**Goal:** Users can log in and access protected routes

See `NEXT_STEPS.md` for detailed guide.

---

**Keep this card handy for quick command lookup!** 📋
