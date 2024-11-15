import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCx22kOaowOw4Os74YkiR300sk_RdJDL64',
    appId: '1:826136080579:android:4400408597fe8dbdcfb276',
    messagingSenderId: '826136080579',
    projectId: 'truesight-cloud-apps',
    storageBucket: 'truesight-cloud-apps.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBagrHJUvYGbqSPnUg4zjQMLe14QGX5hSQ',
    appId: '1:826136080579:ios:4a5f522a13a4b13fcfb276',
    messagingSenderId: '826136080579',
    projectId: 'truesight-cloud-apps',
    storageBucket: 'truesight-cloud-apps.firebasestorage.app',
    androidClientId:
        '826136080579-57cdo0aup2djdr8i5u3n30mdcjhhi2sk.apps.googleusercontent.com',
    iosClientId:
        '826136080579-ugq0o9juck98m1gdh3js0vahptvinnge.apps.googleusercontent.com',
    iosBundleId: 'vn.supa.devops',
  );
}
