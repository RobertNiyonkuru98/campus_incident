import '../../models/app_user.dart';

/// Sealed so the UI must handle every case - the compiler tells you if you
/// forget the error state.
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AppUser user;
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);
  final String message;
}
