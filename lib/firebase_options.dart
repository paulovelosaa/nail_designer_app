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
    apiKey: 'AIzaSyBGUuMs1RHqFJrxNKZIwa05eiQzGy-o468',
    appId: '1:712300337069:web:6c83c8aed9471c54c93324',
    messagingSenderId: '712300337069',
    projectId: 'nail-designer-app-cd536',
    authDomain: 'nail-designer-app-cd536.firebaseapp.com',
    storageBucket: 'nail-designer-app-cd536.firebasestorage.app',
    measurementId: 'G-JY9FXW400W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfXex_vQjNgvfMdB4FfyiX3ZSskL-BD_8',
    appId: '1:712300337069:android:57b788cc3f4f8535c93324',
    messagingSenderId: '712300337069',
    projectId: 'nail-designer-app-cd536',
    storageBucket: 'nail-designer-app-cd536.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDs1zRR4lXBY0jYcMXkRm0MozkWAiYTGWc',
    appId: '1:712300337069:ios:249e39a74722b671c93324',
    messagingSenderId: '712300337069',
    projectId: 'nail-designer-app-cd536',
    storageBucket: 'nail-designer-app-cd536.firebasestorage.app',
    iosBundleId: 'com.example.nailDesignerApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDs1zRR4lXBY0jYcMXkRm0MozkWAiYTGWc',
    appId: '1:712300337069:ios:249e39a74722b671c93324',
    messagingSenderId: '712300337069',
    projectId: 'nail-designer-app-cd536',
    storageBucket: 'nail-designer-app-cd536.firebasestorage.app',
    iosBundleId: 'com.example.nailDesignerApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBGUuMs1RHqFJrxNKZIwa05eiQzGy-o468',
    appId: '1:712300337069:web:a6a5d7f30a3f5029c93324',
    messagingSenderId: '712300337069',
    projectId: 'nail-designer-app-cd536',
    authDomain: 'nail-designer-app-cd536.firebaseapp.com',
    storageBucket: 'nail-designer-app-cd536.firebasestorage.app',
    measurementId: 'G-F736431WN4',
  );
}
