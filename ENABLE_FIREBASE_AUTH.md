# 🔥 ENABLE FIREBASE AUTHENTICATION

## The Problem
Firebase is returning 400 errors because Email/Password authentication is **DISABLED** in your Firebase Console.

```
identitytoolkit.googleapis.com/v1/accounts:signUp?key=... Failed (400)
identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=... Failed (400)
```

## ✅ Solution - Enable Email/Password Auth

### Step 1: Open Firebase Console
1. Go to: https://console.firebase.google.com/
2. Select your project: **my-first-project-e8a6e**

### Step 2: Enable Authentication
1. In the left sidebar, click **Build** → **Authentication**
2. Click **Get Started** (if first time)
3. Click on the **Sign-in method** tab
4. Find **Email/Password** in the list
5. Click on it
6. Toggle **Enable** to ON
7. Click **Save**

### Step 3: Test the App
After enabling, come back and:
1. Press **R** (shift+R) in your Flutter terminal to hot restart
2. Try registering a new account:
   - Name: Moses
   - Role: Nurse
   - Phone: 700000000 (9 digits)
   - PIN: 1234
3. Then try logging in with those credentials

---

## 🎯 What This Enables
- User registration (create account)
- User login
- Password reset
- Email verification (optional)

## 📱 Your Firebase Project
- Project ID: `my-first-project-e8a6e`
- Region: Default
- Auth Domain: `my-first-project-e8a6e.firebaseapp.com`

---

**After enabling, the 400 errors will disappear and authentication will work!**
