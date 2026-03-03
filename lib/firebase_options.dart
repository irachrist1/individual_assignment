// Generated/configured for Firebase project: firstapp-b59c8
// Do not commit this file to version control with sensitive credentials.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web. '
        'Reconfigure using FlutterFire CLI.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_q2GRasPTOJdO6NhEngmlYERZidpDpe8',
    appId: '1:1051571214199:android:953a09622d8897c93c3372',
    messagingSenderId: '1051571214199',
    projectId: 'firstapp-b59c8',
    storageBucket: 'firstapp-b59c8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8TUP4ceYX3LhoxQnpy1ImlWXeWdhSjmE',
    appId: '1:1051571214199:ios:90afacdc19b1679d3c3372',
    messagingSenderId: '1051571214199',
    projectId: 'firstapp-b59c8',
    storageBucket: 'firstapp-b59c8.firebasestorage.app',
    iosBundleId: 'com.example.individualAssignment',
  );
}
