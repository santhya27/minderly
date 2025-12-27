import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB1YaEdU2o4-7du52rF_NJbRmRhL_VrBzQ',
    appId: '1:643567499004:web:638bf8b65f268ea9990979',
    messagingSenderId: '643567499004',
    projectId: 'minderly-5692b',
    authDomain: 'minderly-5692b.firebaseapp.com',
    storageBucket: 'minderly-5692b.firebasestorage.app',
    measurementId: 'G-H932DGPJPN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIZaSyB1YaEdu2d4-7du52rf_NjBRmRhL_VrBzQ',
    appId: '1:643567499004:android:638bf8b65f268ea9990979',
    messagingSenderId: '643567499004',
    projectId: 'minderly-5692b',
    storageBucket: 'minderly-5692b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIZaSyCQn0vYyxc_yABfpI-jx9l8rY8X5HFmD5A',
    appId: '1:643567499004:ios:b8057e274deb21d0990979',
    messagingSenderId: '643567499004',
    projectId: 'minderly-5692b',
    storageBucket: 'minderly-5692b.firebasestorage.app',
    iosBundleId: 'com.example.minderly',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIZaSyCQn0vYyxc_yABfpI-jx9l8rY8X5HFmD5A',
    appId: '1:643567499004:ios:b8057e274deb21d0990979',
    messagingSenderId: '643567499004',
    projectId: 'minderly-5692b',
    storageBucket: 'minderly-5692b.firebasestorage.app',
    iosBundleId: 'com.example.minderly',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIZaSyB1YaEdu2d4-7du52rf_NjBRmRhL_VrBzQ',
    appId: '1:643567499004:web:638bf8b65f268ea9990979',
    messagingSenderId: '643567499004',
    projectId: 'minderly-5692b',
    authDomain: 'minderly-5692b.firebaseapp.com',
    storageBucket: 'minderly-5692b.firebasestorage.app',
    measurementId: 'G-H932DGPJPN',
  );
}