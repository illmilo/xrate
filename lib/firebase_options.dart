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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDnO7R1ltSgL5D4cRl1VHbie1ZPCwCCKA4',
    appId: '1:337987828333:android:d13a1462e8a127d112dd64',
    messagingSenderId: '337987828333',
    projectId: 'transfer-app-e4381',
    storageBucket: 'transfer-app-e4381.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtuS6ALnuhU6c4jsu4M5NAb6u-J_74OF4',
    appId: '1:337987828333:ios:e0a16c6a0513afa612dd64',
    messagingSenderId: '337987828333',
    projectId: 'transfer-app-e4381',
    storageBucket: 'transfer-app-e4381.appspot.com',
    iosBundleId: 'com.example.moneyTransfer',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD5TmsFaj0CHOALMeWS8MrSSXXq-eyYM5Q',
    appId: '1:337987828333:web:618b66d652cd5d8c12dd64',
    messagingSenderId: '337987828333',
    projectId: 'transfer-app-e4381',
    authDomain: 'transfer-app-e4381.firebaseapp.com',
    storageBucket: 'transfer-app-e4381.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBtuS6ALnuhU6c4jsu4M5NAb6u-J_74OF4',
    appId: '1:337987828333:ios:e0a16c6a0513afa612dd64',
    messagingSenderId: '337987828333',
    projectId: 'transfer-app-e4381',
    storageBucket: 'transfer-app-e4381.appspot.com',
    iosBundleId: 'com.example.moneyTransfer',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD5TmsFaj0CHOALMeWS8MrSSXXq-eyYM5Q',
    appId: '1:337987828333:web:870f87ba888374ce12dd64',
    messagingSenderId: '337987828333',
    projectId: 'transfer-app-e4381',
    authDomain: 'transfer-app-e4381.firebaseapp.com',
    storageBucket: 'transfer-app-e4381.appspot.com',
  );

}