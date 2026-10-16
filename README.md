# Nsiika Health Centre IV - Health AI App

A Flutter-based health management system for Nsiika Health Centre IV, enabling healthcare workers to manage patient records, track visits, and monitor facility status.

## Features

- 📱 **Patient Management**: Register and manage patient records
- 🏥 **Visit Tracking**: Record patient visits and medical history
- 📊 **Health Analytics**: AI-powered health predictions and insights
- 🔄 **Offline Support**: Works offline with Firebase persistence
- 📈 **Reports & Statistics**: Generate facility reports and analytics
- 🔐 **Secure Authentication**: Phone-based authentication with PIN

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Cloud Functions)
- **Routing**: GoRouter
- **Charts**: FL Chart
- **Storage**: Flutter Secure Storage

## Getting Started

### Prerequisites

- Flutter SDK (>=3.12.2)
- Dart SDK
- Android Studio / VS Code
- Firebase account

### Installation

1. Clone the repository:
```bash
git clone https://github.com/marthairunva-crypto/health_ai.git
cd health_ai
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Configure Firebase:
   - Add your `google-services.json` to `android/app/`
   - Add your `GoogleService-Info.plist` to `ios/Runner/`
   - Update `lib/firebase_options.dart` with your Firebase config

5. Run the app:
```bash
flutter run
```

## Building

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## CI/CD

This project uses GitHub Actions to automatically build APKs on push to main branches.

- APK artifacts are available in the Actions tab after each build
- Tagged releases (v*) automatically create GitHub releases with APK

## Project Structure

```
lib/
├── core/               # Core utilities, theme, Firebase config
├── features/           # Feature modules
│   ├── auth/          # Authentication
│   ├── dashboard/     # Dashboard
│   ├── patients/      # Patient management
│   ├── visits/        # Visit recording
│   ├── predictions/   # Health predictions
│   ├── facility/      # Facility status
│   ├── reports/       # Reports & analytics
│   └── settings/      # App settings
└── main.dart          # App entry point
```

## Firebase Setup

This app requires the following Firebase services:
- Authentication (Phone Auth)
- Cloud Firestore
- Cloud Functions
- Cloud Messaging (optional)
- Crashlytics (optional)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is proprietary software for Nsiika Health Centre IV.

## Contact

For issues and support, please contact the development team.

---

Built with ❤️ for better healthcare management
