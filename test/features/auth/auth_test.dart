import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/features/auth/data/models/user_model.dart';
import 'package:task_management_app/features/auth/domain/entities/user_entity.dart';

void main() {
  group('Auth Layer Tests', () {
    const testUser = UserModel(
      id: 'user_123',
      email: 'test@example.com',
      displayName: 'Test User',
    );

    test('UserModel is a subclass of UserEntity', () {
      expect(testUser, isA<UserEntity>());
    });

    test('UserModel toJson and fromJson serialization works accurately', () {
      final json = testUser.toJson();
      expect(json['id'], 'user_123');
      expect(json['email'], 'test@example.com');
      expect(json['displayName'], 'Test User');

      final deserialized = UserModel.fromJson(json);
      expect(deserialized, equals(testUser));
    });
  });
}
