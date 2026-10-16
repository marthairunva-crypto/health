# Health AI App - Complete Testing Guide

## 🚀 Quick Start

### 1. Run the App
```bash
flutter run -d chrome
```

### 2. First Time Setup Flow

#### Step 1: Splash Screen (3 seconds)
- Watch the animated Nsiika Health Centre logo
- Auto-navigates to onboarding

#### Step 2: Onboarding (3 screens)
- **Screen 1**: AI-Powered Predictions
- **Screen 2**: Health Records Management  
- **Screen 3**: Real-time Monitoring
- Tap "Get Started" on final screen

#### Step 3: Register New Account
- **Name**: Enter your full name (e.g., "Dr. Sarah Namukasa")
- **Role**: Select from dropdown (Doctor/Nurse/Clinical Officer/Midwife/Lab Technician/Administrator)
- **Phone**: Enter 9 digits (e.g., 701234567 for +256701234567)
- **PIN**: Enter 4-digit PIN (e.g., 1234)
- **Confirm PIN**: Re-enter same PIN
- Tap "Register"

**✅ Success**: You'll be logged in and see the dashboard

## 📱 Testing Each Feature

### Dashboard
**What to verify:**
- [ ] Top stats cards show: Total Patients, Visits Today, High Risk, Low Risk
- [ ] High Risk Alerts section (will be empty initially)
- [ ] Quick Actions grid with 6 options
- [ ] Hamburger menu opens with all navigation options

**Actions:**
- Tap hamburger icon (☰) to open drawer
- Verify all menu items present

---

### 1. New Patient Registration

**Navigate:** Dashboard → Quick Actions → "New Patient" OR Hamburger → "All Patients" → FAB (+)

**Test Case 1: Adult Patient**
- Patient ID: Auto-generated (e.g., P001)
- Name: John Okello
- Age: 35
- Sex: Male
- Tap "Register Patient"

**Test Case 2: Child Patient**
- Name: Grace Auma
- Age: 8
- Sex: Female

**Test Case 3: Elderly Patient**
- Name: Michael Musoke
- Age: 72
- Sex: Male

**✅ Verify:**
- [ ] Patient appears in "All Patients" list
- [ ] Dashboard "Total Patients" count increases
- [ ] Success snackbar shows

---

### 2. Record Visit

**Navigate:** Dashboard → Quick Actions → "Record Visit" OR Hamburger → "Record Visit"

**Test Case 1: High Risk Patient**
- **Patient**: Select John Okello (P001)
- **Vitals:**
  - Blood Pressure: 180/110 (high)
  - Temperature: 39.5°C (fever)
  - Heart Rate: 110 (elevated)
  - Weight: 75 kg
- **Symptoms**: Select "Fever", "Headache", "Chest Pain"
- **Diagnosis**: "Hypertensive Crisis"
- Tap "Save Visit Record"

**Expected Risk Score**: HIGH (70-100) due to high BP, fever, multiple symptoms

**Test Case 2: Moderate Risk Patient**
- **Patient**: Grace Auma (P002)
- **Vitals:**
  - Blood Pressure: 100/70
  - Temperature: 38.2°C (mild fever)
  - Heart Rate: 95
  - Weight: 25 kg
- **Symptoms**: "Fever", "Cough"
- **Diagnosis**: "Upper Respiratory Infection"

**Expected Risk Score**: MODERATE (40-69) due to mild fever and symptoms

**Test Case 3: Low Risk Patient**
- **Patient**: Michael Musoke (P003)
- **Vitals:**
  - Blood Pressure: 130/85
  - Temperature: 36.8°C (normal)
  - Heart Rate: 72
  - Weight: 68 kg
- **Symptoms**: None selected
- **Diagnosis**: "Routine Check-up"

**Expected Risk Score**: LOW (0-39) due to normal vitals

**✅ Verify:**
- [ ] Risk score displays with correct color (red/orange/green)
- [ ] Visit saves successfully
- [ ] Dashboard "Visits Today" count increases
- [ ] High/Low Risk counts update accordingly
- [ ] Patient appears in "High Risk Alerts" if score ≥ 70

---

### 3. AI Predictions

**Navigate:** Dashboard → Quick Actions → "AI Predictions" OR Hamburger → "AI Predictions"

**What to test:**
- [ ] Filter chips work: All / High Risk / Moderate / Low Risk
- [ ] Each prediction card shows:
  - Patient name and ID
  - Risk level with colored indicator
  - Diagnosis
  - Date/time
- [ ] Tap card to see detailed modal with:
  - Full vitals
  - Symptoms list
  - AI recommendations
- [ ] Colors match risk level:
  - Red for High Risk
  - Orange for Moderate Risk
  - Green for Low Risk

**Test actions:**
1. Tap "High Risk" filter → Should show only John Okello
2. Tap "Low Risk" filter → Should show only Michael Musoke
3. Tap "All" → Shows all patients
4. Tap any card → Modal opens with full details
5. Tap "Close" or tap outside → Modal closes

---

### 4. Reports & Analytics

**Navigate:** Dashboard → Quick Actions → "Reports" OR Hamburger → "Reports"

**What to test:**
- [ ] Period filters work: This Week / This Month / This Year
- [ ] Stats grid shows accurate counts:
  - Total Predictions
  - High Risk Cases
  - Moderate Risk Cases
  - Low Risk Cases
- [ ] Risk Distribution bar chart updates with filter
- [ ] Top Diagnoses list shows most common diagnoses with counts

**Test actions:**
1. Select "This Week" → Stats update
2. Select "This Month" → Stats update
3. Select "This Year" → Stats update
4. Verify numbers match your recorded visits
5. Check bar heights reflect proportions correctly

---

### 5. All Patients

**Navigate:** Hamburger → "All Patients"

**What to test:**
- [ ] All registered patients display
- [ ] Each card shows: Name, Patient ID, Age, Sex
- [ ] Search bar filters by name (type "John" → only matching patients)
- [ ] FAB (+) button opens New Patient screen
- [ ] Tap patient card → Opens patient details (future feature)

**Test actions:**
1. Scroll through patient list
2. Use search: type patient name
3. Clear search → All patients return
4. Tap FAB → New Patient screen opens

---

### 6. Facility Status

**Navigate:** Dashboard → Quick Actions → "Facility Status" OR Hamburger → "Facility Status"

**What to test:**
- [ ] "Staff on Duty" section:
  - Shows current count
  - + and - buttons adjust count
  - Count can't go below 0
- [ ] "Medicine Stock Status" section:
  - List of common medicines
  - Each has stock level: In Stock / Low Stock / Out of Stock
  - Tap medicine → Changes status in cycle
  - Color indicators: Green (In Stock), Orange (Low), Red (Out)
- [ ] "Save Status" button updates Firestore
- [ ] Success message shows after save

**Test actions:**
1. Set Staff on Duty to 5
2. Mark Paracetamol as "Low Stock" (tap until orange)
3. Mark Antibiotics as "Out of Stock" (tap until red)
4. Tap "Save Status"
5. Return to dashboard → Facility Status card updates

---

### 7. Settings

**Navigate:** Hamburger → "Settings"

**What to test:**
- [ ] Profile section shows user name and role
- [ ] Notifications toggle works (on/off)
- [ ] Language selector shows options (English, Luganda, Swahili)
- [ ] Dark Mode toggle works (future: changes theme)
- [ ] About section shows app version
- [ ] Privacy Policy opens (placeholder)
- [ ] Help & Support opens (placeholder)
- [ ] Logout confirmation dialog appears
- [ ] Logout returns to login screen

**Test actions:**
1. Toggle Notifications on/off
2. Change language selection
3. Toggle Dark Mode
4. Tap About → Shows version info
5. Tap Logout → Confirmation dialog
6. Cancel → Stays in app
7. Tap Logout → Confirm → Returns to login

---

## 🔄 Data Flow Verification

### Test Complete Workflow
1. ✅ Register as healthcare worker
2. ✅ Add 3 patients (different ages)
3. ✅ Record 3 visits (one high, one moderate, one low risk)
4. ✅ Check predictions screen → All 3 show with correct risk levels
5. ✅ Check reports → Stats reflect 3 predictions
6. ✅ Check dashboard → Counts update correctly
7. ✅ Update facility status → Staff count and medicine stock
8. ✅ Logout and login again → All data persists

---

## 🐛 Common Issues & Solutions

### "No patients found"
- **Cause**: Haven't registered any patients yet
- **Fix**: Use "New Patient" to add patients first

### "No predictions available"
- **Cause**: Haven't recorded any visits yet
- **Fix**: Use "Record Visit" to create visit records with predictions

### "Error loading data"
- **Cause**: Firestore connection issue or permission error
- **Fix**: Check Firebase console, verify Firestore rules are deployed

### Stats showing 0
- **Cause**: No data entered yet OR Firestore date format mismatch
- **Fix**: Record some visits, check Firestore console for data

### High Risk Alerts empty
- **Cause**: No patients with risk score ≥ 70
- **Fix**: Record a visit with high BP (>140/90) or high temp (>38°C) + symptoms

---

## 📊 Expected Data in Firestore

After complete testing, your Firestore should have:

### `/users` collection:
```
{
  uid: "abc123...",
  name: "Dr. Sarah Namukasa",
  phone: "+256701234567",
  role: "Doctor",
  createdAt: timestamp
}
```

### `/patients` collection:
```
{
  patientId: "P001",
  name: "John Okello",
  age: 35,
  sex: "male",
  createdAt: timestamp,
  createdBy: "abc123..."
}
```

### `/visits` collection:
```
{
  visitId: "V001",
  patientId: "P001",
  patientName: "John Okello",
  vitals: { bloodPressure: "180/110", temperature: 39.5, ... },
  symptoms: ["Fever", "Headache", "Chest Pain"],
  diagnosis: "Hypertensive Crisis",
  riskScore: 85,
  riskLevel: "high",
  timestamp: timestamp,
  recordedBy: "abc123..."
}
```

### `/facilityStatus` collection:
```
{
  statusId: "FS_2026-10-11",
  date: "2026-10-11",
  staffOnDuty: 5,
  medicineStock: {
    "Paracetamol": "low",
    "Antibiotics": "out",
    ...
  },
  updatedAt: timestamp,
  updatedBy: "abc123..."
}
```

---

## ✨ Next Steps

1. **Test on Android**: Run `flutter run` with Android device/emulator
2. **Test on iOS**: Run `flutter run` with iOS simulator (Mac only)
3. **Deploy Cloud Functions**: Upgrade to Firebase Blaze plan, then `firebase deploy --only functions`
4. **Add Real AI**: Integrate Groq API in Cloud Functions for advanced predictions
5. **Patient Details**: Create detailed patient profile screen
6. **Visit History**: Show all visits for a patient
7. **Data Export**: Add CSV/PDF export for reports
8. **Offline Mode**: Add local caching for poor connectivity areas

---

## 🎯 Success Criteria

- [ ] Can register and login with phone + PIN
- [ ] Can add patients and see them in the list
- [ ] Can record visits with vitals and symptoms
- [ ] Risk scores calculate correctly based on vitals
- [ ] Predictions screen shows all visits with filters working
- [ ] Reports show accurate statistics
- [ ] Facility status can be updated
- [ ] Dashboard stats update in real-time
- [ ] Settings and logout work correctly
- [ ] All data persists after logout/login

---

**Ready to test!** Start with registration and work through each feature systematically. 🚀
