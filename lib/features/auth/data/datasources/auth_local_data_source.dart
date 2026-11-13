import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  UserModel? getLastUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<dynamic> userBox;
  static const String _userKey = 'CACHED_USER';

  AuthLocalDataSourceImpl({required this.userBox});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await userBox.put(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      throw CacheException('Failed to cache user session: $e');
    }
  }

  @override
  UserModel? getLastUser() {
    try {
      final raw = userBox.get(_userKey);
      if (raw == null) return null;
      final map = jsonDecode(raw as String) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await userBox.delete(_userKey);
    } catch (e) {
      throw CacheException('Failed to clear cached user: $e');
    }
  }
}
