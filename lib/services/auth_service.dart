import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/enums.dart';

/// The only class that talks to Firebase Authentication and `users`.
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  User? get currentUser => _auth.currentUser;

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _loadProfile(cred.user!);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String studentId,
  }) async {
    final UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final User user = cred.user!;

    // The security rules reject this write unless role == 'student', so the
    // client literally cannot mint a staff account.
    await _db.collection('users').doc(user.uid).set(<String, Object?>{
      'uid': user.uid,
      'name': name.trim(),
      'email': email.trim(),
      'role': UserRole.student.firestoreValue,
      'department': '',
      'studentId': studentId.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return AppUser(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
      studentId: studentId.trim(),
    );
  }

  Future<void> signOut() => _auth.signOut();

  /// Loads the profile of the already-signed-in user, without re-authenticating.
  /// Returns null when there is no session.
  Future<AppUser?> loadCurrentProfile() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;
    return _loadProfile(user);
  }

  /// Reads `users/{uid}` to learn the caller's role. This is the single place
  /// the app trusts for "am I staff?", and it comes from the database.
  Future<AppUser> _loadProfile(User user) async {
    final DocumentSnapshot<Map<String, Object?>> doc =
        await _db.collection('users').doc(user.uid).get();

    if (doc.exists) {
      return AppUser.fromMap(user.uid, doc.data()!);
    }

    // Self-heal an account created before its profile was written.
    final AppUser fallback = AppUser(
      uid: user.uid,
      name: user.displayName ?? 'Student',
      email: user.email ?? '',
    );
    await _db
        .collection('users')
        .doc(user.uid)
        .set(<String, Object?>{
          ...fallback.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    return fallback;
  }

  /// Turns Firebase's error codes into sentences a student can act on.
  static String friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'That email address is not valid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email or password is incorrect.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'weak-password':
          return 'Choose a stronger password (8+ characters).';
        case 'too-many-requests':
          return 'Too many attempts. Wait a moment and try again.';
        case 'network-request-failed':
          return 'No connection. Check your internet and retry.';
        default:
          return error.message ?? 'Authentication failed.';
      }
    }
    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'You do not have permission to do that.';
    }
    return 'Something went wrong. Please try again.';
  }
}
