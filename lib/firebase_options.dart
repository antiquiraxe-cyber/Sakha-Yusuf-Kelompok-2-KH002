import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Konfigurasi default Firebase untuk web dan Android.
/// Dihasilkan berdasarkan project: langkah-awal-bik
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBd2HKkUAaEPkoZdfa1ZGkFZthneBq_H_Q',
    appId: '1:128252278910:web:7dad8dc2d1ca00802c402f',
    messagingSenderId: '128252278910',
    projectId: 'langkah-awal-bik',
    authDomain: 'langkah-awal-bik.firebaseapp.com',
    storageBucket: 'langkah-awal-bik.firebasestorage.app',
    measurementId: 'G-JRB2T85CR4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8zaLZBdgGLVwyRLw68Abtj_QWX23aJ64',
    appId: '1:128252278910:android:7d27f06ea56afb962c402f',
    messagingSenderId: '128252278910',
    projectId: 'langkah-awal-bik',
    storageBucket: 'langkah-awal-bik.firebasestorage.app',
  );
}
