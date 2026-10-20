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
    apiKey: 'AIzaSyDummyKeyForNetSalesProject1e503',
    appId: '1:109659837222:web:netsalesappweb',
    messagingSenderId: '109659837222',
    projectId: 'netsales-1e503',
    authDomain: 'netsales-1e503.firebaseapp.com',
    storageBucket: 'netsales-1e503.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForNetSalesProject1e503',
    appId: '1:109659837222:android:netsalesapp',
    messagingSenderId: '109659837222',
    projectId: 'netsales-1e503',
    storageBucket: 'netsales-1e503.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForNetSalesProject1e503',
    appId: '1:109659837222:ios:netsalesappios',
    messagingSenderId: '109659837222',
    projectId: 'netsales-1e503',
    storageBucket: 'netsales-1e503.appspot.com',
    iosBundleId: 'com.smartix.netsales',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForNetSalesProject1e503',
    appId: '1:109659837222:ios:netsalesappios',
    messagingSenderId: '109659837222',
    projectId: 'netsales-1e503',
    storageBucket: 'netsales-1e503.appspot.com',
    iosBundleId: 'com.smartix.netsales',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForNetSalesProject1e503',
    appId: '1:109659837222:web:netsalesappwin',
    messagingSenderId: '109659837222',
    projectId: 'netsales-1e503',
    authDomain: 'netsales-1e503.firebaseapp.com',
    storageBucket: 'netsales-1e503.appspot.com',
  );
}
