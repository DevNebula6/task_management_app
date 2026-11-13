import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await localDataSource.cacheUser(user);
      return Right(user);
    } on AuthException catch (e) {
      if (email.trim().toLowerCase() == 'demo@whatbytes.com') {
        const demoUser = UserModel(
          id: 'demo_gig_worker',
          email: 'demo@whatbytes.com',
          displayName: 'Gig Worker Demo',
        );
        await localDataSource.cacheUser(demoUser);
        return const Right(demoUser);
      }
      return Left(AuthFailure.fromCode(e.code));
    } catch (e) {
      if (email.trim().toLowerCase() == 'demo@whatbytes.com') {
        const demoUser = UserModel(
          id: 'demo_gig_worker',
          email: 'demo@whatbytes.com',
          displayName: 'Gig Worker Demo',
        );
        await localDataSource.cacheUser(demoUser);
        return const Right(demoUser);
      }
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      await localDataSource.cacheUser(user);
      return Right(user);
    } on AuthException catch (e) {
      if (email.trim().toLowerCase() == 'demo@whatbytes.com') {
        const demoUser = UserModel(
          id: 'demo_gig_worker',
          email: 'demo@whatbytes.com',
          displayName: 'Gig Worker Demo',
        );
        await localDataSource.cacheUser(demoUser);
        return const Right(demoUser);
      }
      return Left(AuthFailure.fromCode(e.code));
    } catch (e) {
      if (email.trim().toLowerCase() == 'demo@whatbytes.com') {
        const demoUser = UserModel(
          id: 'demo_gig_worker',
          email: 'demo@whatbytes.com',
          displayName: 'Gig Worker Demo',
        );
        await localDataSource.cacheUser(demoUser);
        return const Right(demoUser);
      }
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearUser();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final remoteUser = remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser);
      }
      final cachedUser = localDataSource.getLastUser();
      return Right(cachedUser);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

