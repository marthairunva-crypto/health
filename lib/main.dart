import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:health_ai/core/theme/app_theme.dart';
import 'package:health_ai/core/firebase/firebase_config.dart';
import 'package:health_ai/features/splash/presentation/splash_screen.dart';
import 'package:health_ai/features/onboarding/presentation/onboarding_screen.dart';
import 'package:health_ai/features/auth/presentation/login_screen.dart';
import 'package:health_ai/features/auth/presentation/register_screen.dart';
import 'package:health_ai/features/dashboard/presentation/dashboard_screen.dart';
import 'package:health_ai/features/patients/presentation/patients_list_screen.dart';
import 'package:health_ai/features/patients/presentation/new_patient_screen.dart';
import 'package:health_ai/features/patients/presentation/patient_details_screen.dart';
import 'package:health_ai/features/patients/presentation/edit_patient_screen.dart';
import 'package:health_ai/features/visits/presentation/record_visit_screen.dart';
import 'package:health_ai/features/predictions/presentation/predictions_screen.dart';
import 'package:health_ai/features/facility/presentation/facility_status_screen.dart';
import 'package:health_ai/features/reports/presentation/reports_screen.dart';
import 'package:health_ai/features/settings/presentation/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    print('❌ Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };
  
  try {
    await FirebaseConfig.initialize();
    print('✅ Firebase initialized successfully');
  } catch (e, stackTrace) {
    print('❌ Firebase initialization error: $e');
    print('Stack trace: $stackTrace');
  }
  
  runApp(
    DevicePreview(
      enabled: false, // Disabled for release
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Device Preview configuration
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: (context, widget) {
        // Wrap with error boundary
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Something went wrong',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      details.exception.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
        };
        
        return DevicePreview.appBuilder(context, widget);
      },
      
      // App configuration
      title: 'Nsiika HC IV',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      
      // Routes
      initialRoute: '/',
      onGenerateRoute: (settings) {
        print('🔍 Navigating to: ${settings.name}');
        
        Widget screen;
        try {
          switch (settings.name) {
            case '/':
              screen = const SplashScreen();
              break;
            case '/onboarding':
              screen = const OnboardingScreen();
              break;
            case '/login':
              print('✅ Creating LoginScreen');
              screen = const LoginScreen();
              break;
            case '/register':
              screen = const RegisterScreen();
              break;
            case '/dashboard':
              screen = const DashboardScreen();
              break;
            case '/patients':
              screen = const PatientsListScreen();
              break;
            case '/new-patient':
              screen = const NewPatientScreen();
              break;
            case '/patient-details':
              screen = const PatientDetailsScreen();
              break;
            case '/edit-patient':
              screen = const EditPatientScreen();
              break;
            case '/record-visit':
              screen = const RecordVisitScreen();
              break;
            case '/predictions':
              screen = const PredictionsScreen();
              break;
            case '/facility-status':
              screen = const FacilityStatusScreen();
              break;
            case '/reports':
              screen = const ReportsScreen();
              break;
            case '/settings':
              screen = const SettingsScreen();
              break;
            default:
              print('❌ Unknown route: ${settings.name}');
              screen = Scaffold(
                body: Center(
                  child: Text('Route not found: ${settings.name}'),
                ),
              );
          }
          
          return MaterialPageRoute(
            builder: (context) => screen,
            settings: settings,
          );
        } catch (e, stack) {
          print('❌ Error creating route ${settings.name}: $e');
          print('Stack: $stack');
          
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading screen',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
