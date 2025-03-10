// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB4QXKJaXeLPE0cpOtZY4uy1mOy73F-I2c',
    appId: '1:319582318965:web:a4a0ea047867ea3f64e33c',
    messagingSenderId: '319582318965',
    projectId: 'collective-rides',
    authDomain: 'collective-rides.firebaseapp.com',
    databaseURL: 'https://collective-rides-default-rtdb.firebaseio.com',
    storageBucket: 'collective-rides.appspot.com',
    measurementId: 'G-09RFVBKRVC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFL7NHIzr8PPw65YBNI-rw3sxZ8B-cG8o',
    appId: '1:319582318965:android:d60d33b551291a1b64e33c',
    messagingSenderId: '319582318965',
    projectId: 'collective-rides',
    databaseURL: 'https://collective-rides-default-rtdb.firebaseio.com',
    storageBucket: 'collective-rides.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCneB8nSSNGtiXhTHlbbAtXStq7bfK6kEI',
    appId: '1:319582318965:ios:2611274d7a22e98264e33c',
    messagingSenderId: '319582318965',
    projectId: 'collective-rides',
    databaseURL: 'https://collective-rides-default-rtdb.firebaseio.com',
    storageBucket: 'collective-rides.appspot.com',
    iosBundleId: 'com.collective.collectiveRider',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCneB8nSSNGtiXhTHlbbAtXStq7bfK6kEI',
    appId: '1:319582318965:ios:2611274d7a22e98264e33c',
    messagingSenderId: '319582318965',
    projectId: 'collective-rides',
    databaseURL: 'https://collective-rides-default-rtdb.firebaseio.com',
    storageBucket: 'collective-rides.appspot.com',
    iosBundleId: 'com.collective.collectiveRider',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB4QXKJaXeLPE0cpOtZY4uy1mOy73F-I2c',
    appId: '1:319582318965:web:53a50adadb469f4d64e33c',
    messagingSenderId: '319582318965',
    projectId: 'collective-rides',
    authDomain: 'collective-rides.firebaseapp.com',
    databaseURL: 'https://collective-rides-default-rtdb.firebaseio.com',
    storageBucket: 'collective-rides.appspot.com',
    measurementId: 'G-94YQ9DXWCB',
  );
}
