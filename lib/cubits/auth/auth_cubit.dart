import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import 'auth_state.dart';

/// Owns "who is signed in, and what is their role".
///
/// The role is loaded from `users/{uid}` and is never read from anything the
/// user can type, which is what makes the staff gate trustworthy.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._service) : super(const AuthInitial());

  final AuthService _service;

  AppUser? get user {
    final AuthState current = state;
    return current is AuthAuthenticated ? current.user : null;
  }

  bool get isStaff => user?.isStaff ?? false;

  /// Called once at startup, after Firebase.initializeApp().
  Future<void> restoreSession() async {
    emit(const AuthLoading());
    try {
      final AppUser? profile = await _service.loadCurrentProfile();
      emit(profile == null
          ? const AuthUnauthenticated()
          : AuthAuthenticated(profile));
    } catch (_) {
      // A failed profile read must not strand the user on a spinner.
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final AppUser profile =
          await _service.signIn(email: email, password: password);
      emit(AuthAuthenticated(profile));
    } catch (error) {
      emit(AuthFailure(AuthService.friendlyError(error)));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String studentId,
  }) async {
    emit(const AuthLoading());
    try {
      final AppUser profile = await _service.register(
        name: name,
        email: email,
        password: password,
        studentId: studentId,
      );
      emit(AuthAuthenticated(profile));
    } catch (error) {
      emit(AuthFailure(AuthService.friendlyError(error)));
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    emit(const AuthUnauthenticated());
  }
}
