# 🚀 START HERE - Local Development

## You Are Here: Local Development Phase

**No deployment needed yet!** Everything runs on your computer.

---

## Step 1: Install Dependencies (5 minutes)

### Flutter Dependencies
```bash
flutter pub get
```
✅ Already done!

### Functions Dependencies
```bash
cd functions
npm install
cd ..
```
⏳ Do this now!

Expected output:
```
added 500+ packages
```

---

## Step 2: Start Emulators (2 minutes)

```bash
firebase emulators:start
```

**What this does:**
- Starts local Firebase services on your computer
- Loads your Groq API key from `.env.local`
- Creates temporary local databases
- No internet needed (except for Groq API calls)
- **Nothing deployed to cloud!**

**Access points:**
- Emulator UI: http://localhost:4000
- Firestore: http://localhost:8080
- Auth: http://localhost:9099
- Functions: http://localhost:5001

Keep this terminal open!

---

## Step 3: Run Flutter App (1 minute)

**In a NEW terminal** (keep emulators running):

```bash
flutter run
```

**What this does:**
- Builds your Flutter app
- Connects to LOCAL emulators (not cloud)
- Shows the placeholder screen
- Hot reload enabled (press 'r' to refresh)

---

## What You Have Now

```
Your Computer
├── Emulators Running (terminal 1)
│   ├── Local Firestore database
│   ├── Local Auth
│   ├── Local Functions
│   └── Groq key loaded from .env.local
│
└── Flutter App Running (terminal 2)
    └── Connected to emulators (not cloud!)
```

**Nothing in the cloud yet!**

---

## Next: Start Building Features

### Phase 2: Authentication (Next)

**Goal:** Login screen that works with local Auth emulator

**Files to create:**
1. `lib/core/firebase/firebase_config.dart` - Initialize Firebase
2. `lib/features/auth/data/auth_repository.dart` - Auth logic
3. `lib/features/auth/presentation/login_screen.dart` - Login UI
4. `lib/core/router/app_router.dart` - Navigation

**See:** `NEXT_STEPS.md` for detailed guide

---

## Phase 5: Prediction Engine (The AI Part)

**When:** After authentication, patients, and visits are working

**Files to implement:**
1. `functions/src/baseline.js` - Rule-based model
2. `functions/src/utils/deidentify.js` - Remove PII
3. `functions/src/groq.js` - Call Groq API
4. `functions/src/predictions.js` - Main prediction logic

**Your Groq key:** Already configured in `.env.local` for emulator testing!

---

## Testing Flow (All Local)

```
1. Start emulators (firebase emulators:start)
   ↓
2. Run Flutter app (flutter run)
   ↓
3. Test login (local Auth emulator)
   ↓
4. Create patient (local Firestore)
   ↓
5. Record visit (local Firestore)
   ↓
6. Request prediction (local Function calls Groq API)
   ↓
7. View result (local Firestore)
```

**All happens on your computer!**

---

## When Do You Deploy? (Much Later!)

### Phase 9: Deployment (4-6 weeks from now)

**Before deploying:**
- [x] Project structure ✅
- [x] Models created ✅
- [x] Groq key configured ✅
- [ ] Authentication working
- [ ] Patients CRUD working
- [ ] Visits recording working
- [ ] Predictions generating working
- [ ] Dashboard showing high-risk patients
- [ ] All features tested locally
- [ ] Tests written and passing
- [ ] Documentation complete

**Then deploy:**
```bash
# 1. Set production secret (one time)
firebase functions:secrets:set GROQ_API_KEY

# 2. Deploy
firebase deploy

# 3. Build APK
flutter build apk --release
```

But that's **weeks away**!

---

## Current Phase: Local Development

**Timeline:**
- Week 1-2: Auth + Patients (local emulators)
- Week 3-4: Visits + Predictions (local emulators)
- Week 5-6: Dashboard + Admin (local emulators)
- Week 7-8: Testing (local emulators)
- Week 9: Deploy to cloud
- Week 10: APK + user testing

**You're in Week 1!**

---

## Commands You'll Use Daily

```bash
# Terminal 1: Start emulators
firebase emulators:start

# Terminal 2: Run app
flutter run

# When you change models
flutter pub run build_runner build --delete-conflicting-outputs

# Check for errors
flutter analyze

# Run tests
flutter test
```

---

## Key Point

🎯 **You develop and test EVERYTHING locally with emulators first.**

🎯 **Deploy to cloud only when everything works locally.**

🎯 **Right now: Just get emulators running and start Phase 2 (Auth).**

---

## Quick Verification

### Check Everything is Ready

1. **Dependencies installed?**
   ```bash
   cd functions && npm list | head -5 && cd ..
   ```
   Should show packages installed.

2. **Emulators start?**
   ```bash
   firebase emulators:start
   ```
   Should show all services running.

3. **App compiles?**
   ```bash
   flutter run --dry-run
   ```
   Should complete without errors.

---

## Your Next Command

```bash
cd functions && npm install && cd ..
```

Then:
```bash
firebase emulators:start
```

**That's it for now!** No deployment needed. 🎉

---

**Questions about local development?** Check:
- `QUICK_REFERENCE.md` - Commands
- `docs/ARCHITECTURE.md` - How it works
- `NEXT_STEPS.md` - What to build next
