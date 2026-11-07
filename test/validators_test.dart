import 'package:campus_incident/core/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.title', () {
    test('rejects empty and whitespace-only', () {
      expect(Validators.title(''), isNotNull);
      expect(Validators.title('   '), isNotNull);
      expect(Validators.title(null), 'Title is required');
    });

    test('rejects shorter than 6 characters', () {
      expect(Validators.title('Tap'), 'Use at least 6 characters');
    });

    test('accepts a realistic title', () {
      expect(Validators.title('Water shortage in Block B'), isNull);
    });

    test('rejects over 80 characters', () {
      expect(Validators.title('x' * 81), isNotNull);
    });
  });

  group('Validators.description', () {
    test('rejects shorter than 15 characters', () {
      expect(Validators.description('Broken tap'), isNotNull);
    });

    test('accepts a detailed description', () {
      expect(
        Validators.description('No water has come out of the tap since 07:00.'),
        isNull,
      );
    });
  });

  group('Validators.email', () {
    test('rejects malformed addresses', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('missing@domain'), isNotNull);
    });

    test('accepts a campus address', () {
      expect(Validators.email('amina@campus.edu'), isNull);
    });
  });

  group('Validators.password', () {
    test('requires 8 characters', () {
      expect(Validators.password('short'), 'Use at least 8 characters');
      expect(Validators.password('longenough'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects a mismatch', () {
      expect(
        Validators.confirmPassword('different', 'longenough'),
        'Passwords do not match',
      );
    });

    test('accepts a match', () {
      expect(Validators.confirmPassword('longenough', 'longenough'), isNull);
    });
  });
}
