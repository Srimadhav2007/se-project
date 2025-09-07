import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDeHLhfJ6ZluYAry3T0AOInd1zd4wyRur4',
    appId: '1:473736664059:web:8b4ebb5e7e5a88e713715e',
    messagingSenderId: '473736664059',
    projectId: 'project-b3fde',
    authDomain: 'project-b3fde.firebaseapp.com',
    storageBucket: 'project-b3fde.firebasestorage.app',
    measurementId: 'G-TB299XBXT5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD3yErWe70o2qhVRttVSmB1NuENFANl3dk',
    appId: '1:473736664059:android:c9143ec49af79d9a13715e',
    messagingSenderId: '473736664059',
    projectId: 'project-b3fde',
    storageBucket: 'project-b3fde.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyByfjnHUo33NznRcG32x9AMIEjrWTWWtaU',
    appId: '1:473736664059:ios:8c83c0fcf786b46f13715e',
    messagingSenderId: '473736664059',
    projectId: 'project-b3fde',
    storageBucket: 'project-b3fde.firebasestorage.app',
    iosBundleId: 'com.example.happinessHub',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyByfjnHUo33NznRcG32x9AMIEjrWTWWtaU',
    appId: '1:473736664059:ios:8c83c0fcf786b46f13715e',
    messagingSenderId: '473736664059',
    projectId: 'project-b3fde',
    storageBucket: 'project-b3fde.firebasestorage.app',
    iosBundleId: 'com.example.happinessHub',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDeHLhfJ6ZluYAry3T0AOInd1zd4wyRur4',
    appId: '1:473736664059:web:e1884dad12af306f13715e',
    messagingSenderId: '473736664059',
    projectId: 'project-b3fde',
    authDomain: 'project-b3fde.firebaseapp.com',
    storageBucket: 'project-b3fde.firebasestorage.app',
    measurementId: 'G-CL31Z3R1W1',
  );
}
