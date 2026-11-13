import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again later.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load local cached data.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);

  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const AuthFailure('The email address is not valid.');
      case 'user-disabled':
        return const AuthFailure('This user account has been disabled.');
      case 'user-not-found':
        return const AuthFailure('No account found with this email.');
      case 'wrong-password':
        return const AuthFailure('Incorrect password. Please try again.');
      case 'invalid-credential':
        return const AuthFailure('Invalid email or password. Please verify your credentials.');
      case 'email-already-in-use':
        return const AuthFailure('An account already exists with this email.');
      case 'weak-password':
        return const AuthFailure('Password is too weak. Please use at least 6 characters.');
      case 'network-request-failed':
        return const AuthFailure('Network error. Please check your internet connection.');
      case 'too-many-requests':
        return const AuthFailure('Too many failed attempts. Please try again later.');
      case 'operation-not-allowed':
        return const AuthFailure('Email/password sign-in is not enabled in Firebase Console.');
      default:
        return AuthFailure('Authentication failed ($code). Please try again.');
    }
  }
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

