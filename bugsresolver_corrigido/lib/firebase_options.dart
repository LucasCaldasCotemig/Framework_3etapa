import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'SUBSTITUA_API_KEY',
    appId: 'SUBSTITUA_APP_ID',
    messagingSenderId: 'SUBSTITUA_SENDER_ID',
    projectId: 'SUBSTITUA_PROJECT_ID',
    authDomain: 'SUBSTITUA_PROJECT_ID.firebaseapp.com',
    storageBucket: 'SUBSTITUA_PROJECT_ID.firebasestorage.app',
  );
}
