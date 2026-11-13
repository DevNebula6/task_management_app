import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/core/utils/date_formatter.dart';
import 'package:task_management_app/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validateEmail returns error for invalid email', () {
      expect(Validators.validateEmail(''), 'Email is required');
      expect(Validators.validateEmail('invalid'), 'Please enter a valid email address');
      expect(Validators.validateEmail('user@test.com'), isNull);
    });

    test('validatePassword requires at least 6 characters', () {
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters');
      expect(Validators.validatePassword('123456'), isNull);
    });
  });

  group('DateFormatter Unit Tests', () {
    test('isToday returns true for current date', () {
      expect(DateFormatter.isToday(DateTime.now()), isTrue);
    });

    test('getSectionName returns Today for current date', () {
      expect(DateFormatter.getSectionName(DateTime.now()), 'Today');
    });
  });
}

