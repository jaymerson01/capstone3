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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAuSyJu9AYx9GrYxLPHowI1TCl05iQQsK8',
    appId: '1:643779102657:web:resqcommunitysafety',
    messagingSenderId: '643779102657',
    projectId: 'resq-community-safety',
    authDomain: 'resq-community-safety.firebaseapp.com',
    storageBucket: 'resq-community-safety.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAuSyJu9AYx9GrYxLPHowI1TCl05iQQsK8',
    appId: '1:643779102657:android:e2a9e8861cd1a3fe9f9140',
    messagingSenderId: '643779102657',
    projectId: 'resq-community-safety',
    storageBucket: 'resq-community-safety.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAuSyJu9AYx9GrYxLPHowI1TCl05iQQsK8',
    appId: '1:643779102657:ios:dummy1234567890',
    messagingSenderId: '643779102657',
    projectId: 'resq-community-safety',
    storageBucket: 'resq-community-safety.firebasestorage.app',
    iosBundleId: 'com.example.communitySafetyApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAuSyJu9AYx9GrYxLPHowI1TCl05iQQsK8',
    appId: '1:643779102657:ios:dummy1234567890',
    messagingSenderId: '643779102657',
    projectId: 'resq-community-safety',
    storageBucket: 'resq-community-safety.firebasestorage.app',
    iosBundleId: 'com.example.communitySafetyApp',
  );
}
