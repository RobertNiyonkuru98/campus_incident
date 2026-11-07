// PLACEHOLDER FILE.
//
// Replace it with the real one by running, once, in this folder:
//
//     flutterfire configure --project=<your-firebase-project-id>
//
// That command regenerates this file for every platform you selected. Until
// then, main.dart catches the initialisation error and shows an on-screen
// instruction instead of a cryptic red screen.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAKrAV6EU25CY6sthvDjLN578k1eFku0Ik',
    appId: '1:634135931410:android:a8ba53b612aabc075e46cb',
    messagingSenderId: '634135931410',
    projectId: 'campuscare-f2e08',
    storageBucket: 'campuscare-f2e08.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAQtBuNSoN8wH0OH1qC3QNUpUuu1EIQCwo',
    appId: '1:634135931410:ios:751b965f8e77fc075e46cb',
    messagingSenderId: '634135931410',
    projectId: 'campuscare-f2e08',
    storageBucket: 'campuscare-f2e08.firebasestorage.app',
    iosBundleId: 'com.campuscare.campusIncident',
  );
}
