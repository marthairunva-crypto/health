# Nsiika HC IV Project Structure

## Overview
```
health_ai/
├── 📱 Flutter App (lib/)
├── ☁️ Cloud Functions (functions/)
├── 🔥 Firebase Config (root)
├── 📚 Documentation (docs/)
├── 🧪 Tests (test/)
└── 🛠️ Tools (tool/)
```

## Detailed Structure

### 📱 Flutter Application (`lib/`)

```
lib/
├── main.dart                      # App entry point
│
├── core/                          # Shared utilities
│   ├── constants/
│   │   ├── app_constants.dart    # App-wide constants
│   │   └── enums.dart            # Core enums (synced with JS)
│   ├── theme/                     # Material 3 theme
│   ├── router/                    # go_router configuration
│   ├── widgets/                   # Shared UI components
│   ├── errors/                    # Custom exceptions
│   ├── utils/                     # Helper functions
│   └── l10n/                      # Localization (en, runyankole)
│
└── features/                      # Feature modules
    │
    ├── auth/                      # Authentication
    │   ├── data/
    │   │   └── user_model.dart   # AppUser model
    │   └── presentation/          # Login, auth widgets
    │
    ├── patients/                  # Patient management
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── patient_model.dart
    │   │   └── repositories/      # Patient repository
    │   └── presentation/          # List, detail, form screens
    │
    ├── visits/                    # Visit recording
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── visit_model.dart
    │   │   └── repositories/
    │   └── presentation/          # 3-step wizard, detail
    │
    ├── predictions/               # Risk predictions ⭐
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── prediction_model.dart
    │   │   └── repositories/
    │   └── presentation/          # Risk display, feedback
    │
    ├── dashboard/                 # Main overview
    │   └── presentation/          # High-risk list, status
    │
    ├── facility/                  # Facility status
    │   ├── data/
    │   │   └── models/
    │   │       └── facility_daily_model.dart
    │   └── presentation/          # Daily entry form
    │
    ├── admin/                     # Administration
    │   └── presentation/          # User mgmt, export
    │
    └── settings/                  # App settings
        └── presentation/
```

### ☁️ Cloud Functions (`functions/`)

```
functions/
├── package.json                   # Node 20 dependencies
├── index.js                       # Function exports
│
└── src/
    ├── constants.js              # JS constants (synced with Dart)
    ├── auth.js                   # ✅ createUser (complete)
    ├── predictions.js            # 🚧 predictRisk (stub)
    ├── triggers.js               # 🚧 onVisitWritten (stub)
    ├── notifications.js          # 🚧 onPredictionCreated (stub)
    ├── exports.js                # 🚧 exportValidationData (stub)
    ├── baseline.js               # 🚧 Rule-based model (to implement)
    ├── prompts/                  # Groq prompt templates
    └── utils/
        ├── deidentify.js         # PII removal
        ├── validation.js         # Input validation
        └── logging.js            # Structured logging
```

### 🔥 Firebase Configuration (root)

```
Root/
├── firebase.json                 # ✅ Firebase & emulator config
├── firestore.rules              # ✅ Security rules (role-based)
├── firestore.indexes.json       # ✅ Query optimization
├── .firebaserc                  # Project aliases
└── .gitignore                   # ✅ Protects secrets
```

### 📚 Documentation (`docs/`)

```
docs/
├── ARCHITECTURE.md              # ✅ System design + mermaid diagrams
├── ASSUMPTIONS.md               # ✅ Clinical assumptions to validate
├── DEPLOY.md                    # ✅ Complete deployment guide
├── CHANGELOG.md                 # ✅ Version tracking
└── PROJECT_SETUP_COMPLETE.md   # ✅ Implementation roadmap
```

### 🧪 Tests (`test/`)

```
test/
├── unit/                        # Dart unit tests
│   ├── models/                  # Model serialization
│   ├── repositories/            # Repository logic
│   └── validators/              # Input validation
│
├── widget/                      # Widget tests
│   ├── auth/                    # Login screen
│   ├── visits/                  # Visit form
│   └── predictions/             # Risk display
│
└── rules/                       # Firestore rules tests
    └── security_test.js         # @firebase/rules-unit-testing
```

### 🛠️ Tools (`tool/`)

```
tool/
├── seed_synthetic_data.dart     # Generate test data
└── evaluate_predictions.py      # Model validation metrics
```

## Key Data Models

### Patient Model
```dart
Patient {
  id, internalCode, sex, birthYear,
  chronicConditions[], createdBy, createdAt
}
+ PatientIdentity (private subcollection)
  { fullName, phoneNumber, village, nin }
```

### Visit Model
```dart
Visit {
  id, patientId, visitDate,
  // Clinical
  presentingComplaint, vitals, triageCategory, referralType,
  // System factors
  waitTimeMinutes, staffOnDuty, stockouts[], shift,
  // Ground truth
  actualOutcome[], outcomeRecordedAt
}
```

### Prediction Model
```dart
Prediction {
  id, visitId, patientId,
  riskLevel, riskScore, consequences[],
  topFactors[], recommendations[],
  source, confidence, needsClinicianReview,
  feedback?
}
```

## Firebase Collections

```
Firestore
├── users/{uid}                  # User accounts & roles
├── patients/{id}                # Patient records
│   └── private/{doc}           # PII subcollection
├── visits/{id}                  # Visit records
├── predictions/{id}             # Risk predictions
├── facilityDaily/{yyyy-MM-dd}  # Daily facility status
└── auditLogs/{id}              # Audit trail
```

## Code Generation

### Generated Files (not in git)
```
*.freezed.dart                   # Freezed immutable classes
*.g.dart                         # JSON serialization
*.mocks.dart                     # Test mocks
```

### Generation Command
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Platform Folders (auto-generated)

```
android/          # Android native code & config
ios/              # iOS native code & config
web/              # Web build configuration
linux/            # Linux desktop support
macos/            # macOS desktop support
windows/          # Windows desktop support
```

## File Count Summary

### Implemented Files
- ✅ Core constants: 2 files
- ✅ Data models: 5 files (+ 10 generated)
- ✅ Functions: 5 files (1 complete, 4 stubs)
- ✅ Firebase config: 3 files
- ✅ Documentation: 5 files
- ✅ Main app: 1 file

### To Implement (Phase 2+)
- 🚧 Authentication: ~5 files
- 🚧 Patients: ~8 files
- 🚧 Visits: ~12 files
- 🚧 Predictions: ~10 files
- 🚧 Dashboard: ~5 files
- 🚧 Facility: ~4 files
- 🚧 Admin: ~6 files
- 🚧 Tests: ~20 files

**Estimated total**: ~100 implementation files

## Dependencies

### Flutter (`pubspec.yaml`)
- **Firebase**: 6 packages
- **State**: Riverpod
- **Navigation**: go_router
- **Models**: Freezed + json_serializable
- **UI**: fl_chart
- **Utils**: connectivity_plus, secure_storage
- **Testing**: 4 packages

### Functions (`package.json`)
- firebase-admin
- firebase-functions (v2)
- axios (for Groq API)
- crypto (for de-identification)

## Important Paths

### Configuration
- Firebase project: `my-first-project-e8a6e`
- Functions region: `europe-west1`
- Emulator UI: `http://localhost:4000`

### Secrets (never commit!)
- Groq API key: Firebase Functions secret
- Service accounts: Auto-managed by Firebase

### Git Protection
`.gitignore` blocks:
- `**/*secret*`, `**/*GROQ*`, `**/*groq*`
- `.env`, functions/node_modules/
- `*.g.dart`, `*.freezed.dart`
- Firebase debug logs

## Quick Navigation

| What | Where |
|------|-------|
| Data models | `lib/features/*/data/models/` |
| UI screens | `lib/features/*/presentation/` |
| Cloud Functions | `functions/src/` |
| Constants | `lib/core/constants/`, `functions/src/constants.js` |
| Security rules | `firestore.rules` |
| Documentation | `docs/` |
| Tests | `test/` |

## Status Legend
- ✅ Complete & working
- 🚧 Stub / To implement
- ⭐ Core feature
- 📱 Flutter code
- ☁️ Cloud Functions
- 🔥 Firebase config

---

**Last Updated**: Project setup complete - Phase 1 finished
**Next Phase**: Authentication implementation
