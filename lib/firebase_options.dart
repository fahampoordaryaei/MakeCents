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
    apiKey: 'AIzaSyD9hVgMWvxss8bCpiiFY3B2TiixpYl2gKw',
    appId: '1:1018177450899:web:435a38c15a842bbf33ee66',
    messagingSenderId: '1018177450899',
    projectId: 'makecents-b0fb9',
    authDomain: 'makecents-b0fb9.firebaseapp.com',
    storageBucket: 'makecents-b0fb9.firebasestorage.app',
    measurementId: 'G-8E7CNDYPBM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCL3SNePK9ODpQHwigcIsP57XuX31KMw0M',
    appId: '1:1018177450899:android:759585dec6a4d81b33ee66',
    messagingSenderId: '1018177450899',
    projectId: 'makecents-b0fb9',
    storageBucket: 'makecents-b0fb9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD6GbrEZeCvzORtJmF7w37edNsIg3-Xt-I',
    appId: '1:1018177450899:ios:7371e9838a1b5dbe33ee66',
    messagingSenderId: '1018177450899',
    projectId: 'makecents-b0fb9',
    storageBucket: 'makecents-b0fb9.firebasestorage.app',
    iosBundleId: 'com.makecents.makecents',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD6GbrEZeCvzORtJmF7w37edNsIg3-Xt-I',
    appId: '1:1018177450899:ios:7371e9838a1b5dbe33ee66',
    messagingSenderId: '1018177450899',
    projectId: 'makecents-b0fb9',
    storageBucket: 'makecents-b0fb9.firebasestorage.app',
    iosBundleId: 'com.makecents.makecents',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD9hVgMWvxss8bCpiiFY3B2TiixpYl2gKw',
    appId: '1:1018177450899:web:c9e53975c7dc210b33ee66',
    messagingSenderId: '1018177450899',
    projectId: 'makecents-b0fb9',
    authDomain: 'makecents-b0fb9.firebaseapp.com',
    storageBucket: 'makecents-b0fb9.firebasestorage.app',
    measurementId: 'G-7XZCBRJ8S1',
  );

}