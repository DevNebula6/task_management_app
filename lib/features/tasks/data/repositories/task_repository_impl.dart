import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Stream<List<TaskEntity>> getTasksStream(String userId) {
    late StreamController<List<TaskEntity>> controller;
    StreamSubscription? remoteSub;

    controller = StreamController<List<TaskEntity>>.broadcast(
      onListen: () {
        // Emit cached tasks right away
        final cached = localDataSource.getCachedTasks(userId: userId);
        controller.add(cached);

        // Listen to remote changes
        try {
          remoteSub = remoteDataSource.getTasksStream(userId).listen(
            (remoteTasks) async {
              await localDataSource.cacheTasks(remoteTasks);
              final updated = localDataSource.getCachedTasks(userId: userId);
              controller.add(updated);
            },
            onError: (err) {
              // Remote stream failed (e.g. offline or rules). Keep emitting local
              final fallback = localDataSource.getCachedTasks(userId: userId);
              controller.add(fallback);
            },
          );
        } catch (_) {
          final fallback = localDataSource.getCachedTasks(userId: userId);
          controller.add(fallback);
        }
      },
      onCancel: () {
        remoteSub?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks(String userId) async {
    try {
      final cached = localDataSource.getCachedTasks(userId: userId);
      try {
        final remote = await remoteDataSource.getTasks(userId);
        await localDataSource.cacheTasks(remote);
        final fresh = localDataSource.getCachedTasks(userId: userId);
        return Right(fresh);
      } catch (_) {
        return Right(cached);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    try {
      // 1. Write to local cache first (instant optimistic response)
      await localDataSource.cacheTask(model);

      // 2. Sync to remote
      try {
        await remoteDataSource.createTask(model);
      } catch (_) {
        // Cached locally, will sync when online
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    try {
      await localDataSource.cacheTask(model);
      try {
        await remoteDataSource.updateTask(model);
      } catch (_) {
        // Cached locally
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId, String userId) async {
    try {
      await localDataSource.removeTask(taskId);
      try {
        await remoteDataSource.deleteTask(taskId, userId);
      } catch (_) {
        // Deleted locally
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleTaskStatus(
    String taskId,
    String userId,
    bool isCompleted,
  ) async {
    try {
      await localDataSource.toggleTaskStatus(taskId, isCompleted);
      try {
        await remoteDataSource.toggleTaskStatus(taskId, userId, isCompleted);
      } catch (_) {
        // Toggled locally
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
