import 'package:firebase_core/firebase_core.dart';
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não configurado para esta plataforma. '
          'Execute "flutterfire configure" para gerar este arquivo automaticamente.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'SUBSTITUA_COM_SUA_API_KEY',
    appId: 'SUBSTITUA_COM_SEU_APP_ID',
    messagingSenderId: 'SUBSTITUA',
    projectId: 'SUBSTITUA_COM_SEU_PROJECT_ID',
    storageBucket: 'SUBSTITUA.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SUBSTITUA_COM_SUA_API_KEY',
    appId: 'SUBSTITUA_COM_SEU_APP_ID',
    messagingSenderId: 'SUBSTITUA',
    projectId: 'SUBSTITUA_COM_SEU_PROJECT_ID',
    storageBucket: 'SUBSTITUA.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'SUBSTITUA_COM_SUA_API_KEY',
    appId: 'SUBSTITUA_COM_SEU_APP_ID',
    messagingSenderId: 'SUBSTITUA',
    projectId: 'SUBSTITUA_COM_SEU_PROJECT_ID',
    storageBucket: 'SUBSTITUA.appspot.com',
    iosBundleId: 'com.example.centralDeMissoes',
  );
}
