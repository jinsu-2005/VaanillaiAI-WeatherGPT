// File generated for VaanilaiAI Firebase integration
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA8lGVoA-g_HEbmx_bsVdgw-e3WllujStE',
    appId: '1:380758138825:web:aad069d5f5688622dad218',
    messagingSenderId: '380758138825',
    projectId: 'vaanilai-ai',
    authDomain: 'vaanilai-ai.firebaseapp.com',
    storageBucket: 'vaanilai-ai.firebasestorage.app',
    measurementId: 'G-8D32V25FDQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRPPhVU51sG20zuMdAaXx9wYaWTR32lsc',
    appId: '1:380758138825:android:571b242b6ac5adc0dad218',
    messagingSenderId: '380758138825',
    projectId: 'vaanilai-ai',
    storageBucket: 'vaanilai-ai.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8lGVoA-g_HEbmx_bsVdgw-e3WllujStE',
    appId: '1:380758138825:web:aad069d5f5688622dad218',
    messagingSenderId: '380758138825',
    projectId: 'vaanilai-ai',
    storageBucket: 'vaanilai-ai.firebasestorage.app',
  );
}
