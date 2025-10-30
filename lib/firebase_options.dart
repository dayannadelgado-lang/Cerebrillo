// File generated manually for the new Firebase project cerebrillo-e0c67
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        're-run FlutterFire CLI if needed.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1i6WsCKfcnhDoYKcKIUdSweZPJ6EIqE8',
    appId: '1:279685773221:android:bf40f313aba5218527da4c',
    messagingSenderId: '279685773221',
    projectId: 'cerebrillo-e0c67',
    storageBucket: 'cerebrillo-e0c67.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1i6WsCKfcnhDoYKcKIUdSweZPJ6EIqE8',
    appId: '1:279685773221:ios:bf40f313aba5218527da4c',
    messagingSenderId: '279685773221',
    projectId: 'cerebrillo-e0c67',
    storageBucket: 'cerebrillo-e0c67.appspot.com',
    iosClientId:
        '279685773221-xxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com', // reemplaza si tienes
    iosBundleId: 'com.cerebrillo2.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC1i6WsCKfcnhDoYKcKIUdSweZPJ6EIqE8',
    appId: '1:279685773221:macos:bf40f313aba5218527da4c',
    messagingSenderId: '279685773221',
    projectId: 'cerebrillo-e0c67',
    storageBucket: 'cerebrillo-e0c67.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC1i6WsCKfcnhDoYKcKIUdSweZPJ6EIqE8',
    appId: '1:279685773221:windows:bf40f313aba5218527da4c',
    messagingSenderId: '279685773221',
    projectId: 'cerebrillo-e0c67',
    storageBucket: 'cerebrillo-e0c67.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyC1i6WsCKfcnhDoYKcKIUdSweZPJ6EIqE8',
    appId: '1:279685773221:linux:bf40f313aba5218527da4c',
    messagingSenderId: '279685773221',
    projectId: 'cerebrillo-e0c67',
    storageBucket: 'cerebrillo-e0c67.appspot.com',
  );
}
