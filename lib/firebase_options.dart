

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBMIvQEIk-HoBrVflZKLGgCHl47NpV_7a4',
    appId: '1:483259448504:web:ed1a3128d7553107d5084d',
    messagingSenderId: '483259448504',
    projectId: 'social-feed-app-2025',
    authDomain: 'social-feed-app-2025.firebaseapp.com',
    storageBucket: 'social-feed-app-2025.firebasestorage.app',
    measurementId: 'G-1Q84QTKJ7N',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDPx4JkQR8D30jKUd9u_0sh6Td3Vqz8zE',
    appId: '1:483259448504:android:6aa3eaa6e5036080d5084d',
    messagingSenderId: '483259448504',
    projectId: 'social-feed-app-2025',
    storageBucket: 'social-feed-app-2025.firebasestorage.app',
  );
}

