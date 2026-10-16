# 🚀 Next Steps - Implementation Guide

## Current Status: Phase 1 Complete ✅

Your Nsiika HC IV project foundation is ready!

## Immediate Todo (Before Starting Phase 2)

### 1. Install Firebase Functions Dependencies
```bash
cd functions
npm install
cd ..
```

Expected packages:
- firebase-admin
- firebase-functions (v2)
- axios
- crypto

### 2. Test Firebase Emulators
```bash
firebase emulators:start
```

Should start:
- ✅ Auth emulator: http://localhost:9099
- ✅ Firestore emulator: http://localhost:8080
- ✅ Functions emulator: http://localhost:5001
- ✅ Emulator UI: http://localhost:4000

### 3. Verify Flutter App Runs
```bash
# In a new terminal
flutter run
```

Expected: Placeholder home screen with "Project Setup Complete" message

### 4. Review Documentation
Read these in order:
1. `docs/ARCHITECTURE.md` - Understand the system design
2. `docs/ASSUMPTIONS.md` - Clinical assumptions to validate
3. `docs/DEPLOY.md` - Deployment process

## Phase 2: Authentication (Next) 🔐

**Goal**: Users can log in and access role-based features

### Tasks
1. **Create Auth Repository** (`lib/features/auth/data/auth_repository.dart`)
   - Sign in with email/password
   - Sign out
   - Get current user
   - Listen to auth state changes
   - Extract role from custom claims

2. **Create Auth Providers** (`lib/features/auth/presentation/providers/`)
   - `authStateProvider` - Stream of current user
   - `currentUserProvider` - Current user or null
   - `userRoleProvider` - User's role (clinician/admin)

3. **Build Login Screen** (`lib/features/auth/presentation/login_screen.dart`)
   - Email field (validation)
   - Password field (obscured)
   - Sign in button
   - Error display
   - Loading state
   - "Forgot password?" link

4. **Configure Router** (`lib/core/router/app_router.dart`)
   - Define routes with go_router
   - Auth redirect guard
   - Role-based route protection
   - Deep linking support

5. **Update Main.dart**
   - Initialize Firebase
   - Enable Firestore offline persistence
   - Wrap app with ProviderScope
   - Use router configuration

### Files to Create
```
lib/features/auth/
├── data/
│   ├── auth_repository.dart          # Firebase Auth operations
│   └── user_model.dart               # ✅ Already created
├── presentation/
│   ├── login_screen.dart             # Login UI
│   ├── providers/
│   │   ├── auth_state_provider.dart  # Auth stream
│   │   └── login_controller.dart     # Login logic
│   └── widgets/
│       └── error_message.dart        # Error display widget

lib/core/
├── router/
│   └── app_router.dart               # Route configuration
└── firebase/
    └── firebase_config.dart          # Initialize Firebase
```

### Success Criteria
- [ ] User can log in with email/password
- [ ] Invalid credentials show error
- [ ] Successful login navigates to dashboard (placeholder)
- [ ] User role detected from custom claims
- [ ] Admin can access admin routes
- [ ] Logout works and returns to login
- [ ] App remembers logged-in user after restart
- [ ] Offline persistence enabled

### Testing
```dart
// test/unit/auth/auth_repository_test.dart
- Test sign in success
- Test sign in with wrong password
- Test sign out
- Test role extraction from claims

// test/widget/auth/login_screen_test.dart
- Test form validation
- Test error display
- Test loading state
- Test navigation after login
```

### Before You Start Phase 2
- [ ] Review Flutter Riverpod docs: https://riverpod.dev/
- [ ] Review go_router docs: https://pub.dev/packages/go_router
- [ ] Understand Firebase Auth custom claims
- [ ] Check Firebase Auth emulator works

## Phase 3: Patient Management 🏥

**Goal**: Clinicians can create, view, and search patients

### Key Features
- Patient list with search
- Patient detail view
- Create new patient form
- Private identity management
- Offline support

### Main Files
- `PatientRepository` - CRUD operations
- `PatientListScreen` - Searchable list
- `PatientDetailScreen` - View patient
- `PatientFormScreen` - Create/edit
- Riverpod providers for state

## Phase 4: Visit Recording 📝

**Goal**: Record visit data (clinical + system factors)

### Key Features
- 3-step wizard (Clinical → System → Review)
- Form validation
- Clinically implausible value warnings
- Autosave drafts
- Offline entry support

### Main Files
- `VisitRepository`
- `VisitWizardScreen` (stepper)
- `ClinicalDataForm`
- `SystemFactorsForm`
- `ReviewSubmitScreen`

## Phase 5: Prediction Engine ⭐ (Core Feature)

**Goal**: Generate AI risk predictions

### Backend Tasks (Cloud Functions)
1. **Baseline Model** (`functions/src/baseline.js`)
   - Implement rule-based scoring
   - Define clinical thresholds
   - Test with synthetic data

2. **De-identification** (`functions/src/utils/deidentify.js`)
   - Strip PII from visit data
   - Scrub presenting complaint
   - Validate no identifiers leak

3. **Groq Integration** (`functions/src/groq.js`)
   - Call Groq API
   - Parse JSON response
   - Handle errors/timeouts
   - Implement caching

4. **predictRisk Function** (`functions/src/predictions.js`)
   - Load visit data
   - De-identify
   - Call both baseline & Groq
   - Merge results
   - Save prediction
   - Rate limiting

### Frontend Tasks (Flutter)
1. **Prediction Repository**
   - Call predictRisk function
   - Handle offline queue
   - Save feedback

2. **Risk Display UI**
   - Color-coded risk card
   - Consequence probabilities (bar chart)
   - Top factors list
   - Recommendations
   - Missing data notice
   - Source indicator (Groq/baseline)
   - Disclaimer
   - Feedback buttons

### Success Criteria
- [ ] Baseline model produces sensible scores
- [ ] Groq integration works (with API key)
- [ ] No PII sent to Groq (verified in logs)
- [ ] Fallback to baseline when Groq fails
- [ ] Predictions work offline (queue + retry)
- [ ] Risk display is clear and accessible
- [ ] Feedback saved to Firestore

## Phase 6: Dashboard & Notifications 📊

**Goal**: Overview of high-risk patients

### Key Features
- Today's high/critical risk patients
- Facility status widget
- Pending sync indicator
- FCM notifications for critical risk

### Main Files
- `DashboardScreen`
- `HighRiskPatientList`
- `FacilityStatusCard`
- `onPredictionCreated` trigger
- FCM token management

## Phase 7: Facility & Admin 👨‍💼

**Goal**: Daily facility data & user management

### Facility Features
- Daily staffing entry
- Stock-outs list
- Quick access from dashboard

### Admin Features
- Create user accounts
- List/disable users
- Export validation data
- View audit logs

### Main Files
- `FacilityDailyScreen`
- `UserManagementScreen`
- `ExportDataScreen`
- `createUser` function (✅ already done)
- `exportValidationData` function

## Phase 8: Testing & Validation 🧪

**Goal**: Comprehensive testing & model validation

### Unit Tests
- [ ] All models serialize correctly
- [ ] Repositories handle errors
- [ ] Validators reject bad input
- [ ] De-identification removes PII
- [ ] Baseline model scoring

### Widget Tests
- [ ] Login form validation
- [ ] Visit wizard navigation
- [ ] Risk card displays correctly
- [ ] Error states render

### Integration Tests
- [ ] End-to-end: Login → Create patient → Record visit → View prediction
- [ ] Offline mode works
- [ ] Sync resumes after reconnect

### Rules Tests
```javascript
// test/rules/security_test.js
- Unauthenticated users denied
- Clinicians can read/write visits
- Only functions can create predictions
- Only functions can write audit logs
- Admins can read audit logs
```

### Model Validation
```python
# tool/evaluate_predictions.py
- Load visits with outcomes
- Calculate sensitivity, specificity
- Generate ROC curve
- Compare Groq vs baseline
- Output metrics report
```

## Phase 9: Polish & Deployment 🎨

**Goal**: Production-ready app

### Tasks
- [ ] Add Runyankole translations
- [ ] Improve UI/UX based on feedback
- [ ] Optimize performance
- [ ] Generate synthetic data (marked as such)
- [ ] Write final documentation
- [ ] User testing (SUS questionnaire)
- [ ] Set Groq API key secret
- [ ] Deploy Firebase backend
- [ ] Build release APK
- [ ] Install on test devices

## Timeline Estimate

| Phase | Estimated Time | Status |
|-------|----------------|--------|
| 1. Setup | 1-2 days | ✅ Complete |
| 2. Auth | 2-3 days | 🔜 Next |
| 3. Patients | 3-4 days | ⏳ |
| 4. Visits | 4-5 days | ⏳ |
| 5. Predictions | 5-7 days | ⏳ Core |
| 6. Dashboard | 2-3 days | ⏳ |
| 7. Facility/Admin | 3-4 days | ⏳ |
| 8. Testing | 4-5 days | ⏳ |
| 9. Polish | 3-5 days | ⏳ |
| **Total** | **27-38 days** | |

*Adjust based on your schedule and experience level*

## Development Tips

### Daily Workflow
1. Start emulators: `firebase emulators:start`
2. Run app: `flutter run` (hot reload enabled)
3. Make changes
4. Test manually in emulator
5. Write tests for new features
6. Run `flutter analyze` before commits
7. Update `docs/CHANGELOG.md`

### Debugging
- **Flutter**: Use DevTools, print statements
- **Functions**: Check logs at http://localhost:4000
- **Firestore**: View data in emulator UI
- **Auth**: Check emulator's Auth tab

### Code Generation
After modifying models:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Git Workflow
```bash
git add .
git commit -m "feat: implement user authentication"
git push
```

Use conventional commits: `feat:`, `fix:`, `docs:`, `test:`, etc.

## Resources

### Flutter
- Riverpod: https://riverpod.dev/
- go_router: https://pub.dev/packages/go_router
- Freezed: https://pub.dev/packages/freezed
- Material 3: https://m3.material.io/

### Firebase
- Firestore: https://firebase.google.com/docs/firestore
- Functions: https://firebase.google.com/docs/functions
- Auth: https://firebase.google.com/docs/auth
- Rules: https://firebase.google.com/docs/firestore/security/get-started

### Groq
- API docs: https://console.groq.com/docs
- Models: https://console.groq.com/docs/models
- Pricing: https://groq.com/pricing

### Design
- Material Design: https://m3.material.io/
- Accessibility: https://www.w3.org/WAI/WCAG21/quickref/
- Health UX: Keep it simple, clear, fast

## Questions to Answer Before Phase 5

### Clinical (ask facility staff)
1. What are the common presenting complaints?
2. Which medicines are frequently out of stock?
3. What's the typical staffing level per shift?
4. How do you currently identify high-risk patients?
5. What outcomes do you track?

### Technical
1. Do you have a Groq API account?
2. What's your target device spec (RAM, Android version)?
3. Is internet available at least once daily?
4. How will APKs be distributed? (side-loading, internal store)

## Success Metrics

### Technical
- [ ] App compiles without errors
- [ ] All tests pass
- [ ] `flutter analyze` clean
- [ ] Works offline for data entry
- [ ] Predictions < 5 seconds online
- [ ] No secrets in git history

### Functional
- [ ] Users can log in
- [ ] Patients can be created/searched
- [ ] Visits can be recorded offline
- [ ] Predictions generate and display
- [ ] High-risk patients show in dashboard
- [ ] Feedback can be submitted

### Research/Academic
- [ ] Model validation complete (metrics calculated)
- [ ] User testing done (SUS scores)
- [ ] Documentation complete
- [ ] Code well-commented
- [ ] Assumptions documented
- [ ] Ethical considerations addressed

## Getting Help

### Documentation
- `README.md` - Project overview
- `docs/ARCHITECTURE.md` - System design
- `docs/DEPLOY.md` - Deployment
- `docs/ASSUMPTIONS.md` - Clinical assumptions
- `PROJECT_STRUCTURE.md` - File organization
- `SETUP_SUMMARY.md` - Current status

### Community
- Flutter Discord: https://discord.gg/flutter
- Firebase Discord: https://discord.gg/firebase
- Stack Overflow: Tag with `flutter`, `firebase`, `dart`

### Code Review
Before moving to next phase:
1. All features working
2. Tests written
3. Code analyzed
4. Documentation updated
5. CHANGELOG.md updated

---

## 🎯 Your Immediate Next Action

**Start Phase 2: Authentication**

1. Read: `docs/ARCHITECTURE.md` (Auth section)
2. Create: `lib/core/firebase/firebase_config.dart`
3. Create: `lib/features/auth/data/auth_repository.dart`
4. Run emulators and start coding!

**You've got this!** The foundation is solid. Take it one phase at a time. 🚀

---

**Questions?** Check the docs first, then reach out to your supervisor or community.
