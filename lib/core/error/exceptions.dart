class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server exception occurred']);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache exception occurred']);

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String code;
  final String message;
  const AuthException(this.code, [this.message = 'Auth exception occurred']);

  @override
  String toString() => 'AuthException($code): $message';
}
