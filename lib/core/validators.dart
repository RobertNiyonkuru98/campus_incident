/// Every form rule in one file, as pure functions.
///
/// Pure functions because they are the easiest thing in the app to unit test:
/// no Firebase, no widgets, no build context. `test/validators_test.dart`
/// covers every branch here.
class Validators {
  const Validators._();

  static String? title(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'Title is required';
    if (text.length < 6) return 'Use at least 6 characters';
    if (text.length > 80) return 'Keep it under 80 characters';
    return null;
  }

  static String? description(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'Description is required';
    if (text.length < 15) return 'Give at least 15 characters of detail';
    if (text.length > 600) return 'Keep it under 600 characters';
    return null;
  }

  static String? location(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'Location is required';
    return null;
  }

  static String? email(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'Email is required';
    final RegExp pattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!pattern.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 8) return 'Use at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? fullName(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'Full name is required';
    if (text.length < 3) return 'Enter your full name';
    return null;
  }
}
