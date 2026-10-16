import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:health_ai/firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      // Use the generated Firebase options for all platforms
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Enable offline persistence
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      if (kDebugMode) {
        print('✅ Firebase initialized with offline persistence');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('⚠️ Firebase initialization error: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  static bool get isInitialized => Firebase.apps.isNotEmpty;
}
