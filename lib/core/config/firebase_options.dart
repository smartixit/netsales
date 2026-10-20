import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// إعدادات تهيئة فايربيس الافتراضية لمنظومة NetSales
/// متطابقة مع مشروع netsales-1e503
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
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCZCVHRKz2NP5qyu3_Sce4T7fF0ZE66H_Q',
    appId: '1:735757446098:web:5d84e11b58a0e728d8760b',
    messagingSenderId: '735757446098',
    projectId: 'netsales-1e503',
    authDomain: 'netsales-1e503.firebaseapp.com',
    storageBucket: 'netsales-1e503.firebasestorage.app',
    measurementId: 'G-K8HGPSQBB7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAUtXtC1T8UEZUaOXPAMr67NaNXcMovI8',
    appId: '1:735757446098:android:8bc4bcf18c1f0ad1d8760b',
    messagingSenderId: '735757446098',
    projectId: 'netsales-1e503',
    storageBucket: 'netsales-1e503.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA1e98NJfqOWXZ4awlQTSyksSBEhIfolmY',
    appId: '1:735757446098:ios:d567f823c4f15c59d8760b',
    messagingSenderId: '735757446098',
    projectId: 'netsales-1e503',
    storageBucket: 'netsales-1e503.firebasestorage.app',
    iosBundleId: 'com.smartix.netsales',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA1e98NJfqOWXZ4awlQTSyksSBEhIfolmY',
    appId: '1:735757446098:ios:d567f823c4f15c59d8760b',
    messagingSenderId: '735757446098',
    projectId: 'netsales-1e503',
    storageBucket: 'netsales-1e503.firebasestorage.app',
    iosBundleId: 'com.smartix.netsales',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCZCVHRKz2NP5qyu3_Sce4T7fF0ZE66H_Q',
    appId: '1:735757446098:web:59d8560d27bf31ddd8760b',
    messagingSenderId: '735757446098',
    projectId: 'netsales-1e503',
    authDomain: 'netsales-1e503.firebaseapp.com',
    storageBucket: 'netsales-1e503.firebasestorage.app',
    measurementId: 'G-TKWVRPTDVY',
  );
}
