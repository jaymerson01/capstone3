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
    apiKey: 'dummy-api-key-replace-me',
    appId: '1:123456789012:web:dummy1234567890',
    messagingSenderId: '123456789012',
    projectId: 'dummy-project-id',
    authDomain: 'dummy-project-id.firebaseapp.com',
    storageBucket: 'dummy-project-id.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'dummy-api-key-replace-me',
    appId: '1:123456789012:android:dummy1234567890',
    messagingSenderId: '123456789012',
    projectId: 'dummy-project-id',
    storageBucket: 'dummy-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'dummy-api-key-replace-me',
    appId: '1:123456789012:ios:dummy1234567890',
    messagingSenderId: '123456789012',
    projectId: 'dummy-project-id',
    storageBucket: 'dummy-project-id.appspot.com',
    iosBundleId: 'com.example.communitySafetyApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'dummy-api-key-replace-me',
    appId: '1:123456789012:ios:dummy1234567890',
    messagingSenderId: '123456789012',
    projectId: 'dummy-project-id',
    storageBucket: 'dummy-project-id.appspot.com',
    iosBundleId: 'com.example.communitySafetyApp',
  );
}
