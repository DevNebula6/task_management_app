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

  final StreamController<List<TaskEntity>> _tasksController =
      StreamController<List<TaskEntity>>.broadcast();
  StreamSubscription? _remoteSub;
  StreamSubscription? _localSub;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  void _notify(String userId) {
    if (!_tasksController.isClosed) {
      final cached = localDataSource.getCachedTasks(userId: userId);
      _tasksController.add(cached);
    }
  }

  @override
  Stream<List<TaskEntity>> getTasksStream(String userId) {
    // 1. Initial cached tasks or seed samples
    var cached = localDataSource.getCachedTasks(userId: userId);
    if (cached.isEmpty) {
      final samples = _createSampleTasks(userId);
      localDataSource.cacheTasks(samples).then((_) {
        _notify(userId);
      });
    }

    // 2. Watch local Hive box
    _localSub?.cancel();
    _localSub = localDataSource.watchTasks(userId: userId).listen((tasks) {
      if (!_tasksController.isClosed) {
        _tasksController.add(tasks);
      }
    });

    // 3. Listen to remote changes
    _remoteSub?.cancel();
    try {
      _remoteSub = remoteDataSource.getTasksStream(userId).listen(
        (remoteTasks) async {
          if (remoteTasks.isNotEmpty) {
            await localDataSource.cacheTasks(remoteTasks);
          }
          _notify(userId);
        },
        onError: (_) {
          _notify(userId);
        },
      );
    } catch (_) {
      _notify(userId);
    }

    return Stream<List<TaskEntity>>.multi((multiController) {
      final initial = localDataSource.getCachedTasks(userId: userId);
      if (initial.isNotEmpty) {
        multiController.add(initial);
      }
      final sub = _tasksController.stream.listen(
        multiController.add,
        onError: multiController.addError,
      );
      multiController.onCancel = () => sub.cancel();
    });
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
      _notify(task.userId);

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
      _notify(task.userId);
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
      _notify(userId);
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
      _notify(userId);
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

  List<TaskModel> _createSampleTasks(String userId) {
    final now = DateTime.now();
    return [
      TaskModel(
        id: 'sample_1',
        userId: userId,
        title: 'Schedule dentist appointment',
        description: 'Routine six-month checkup and cleaning',
        dueDate: DateTime(now.year, now.month, now.day, 10, 0),
        priority: TaskPriority.low,
        isCompleted: false,
        createdAt: now,
      ),
      TaskModel(
        id: 'sample_2',
        userId: userId,
        title: 'Prepare team meeting',
        description: 'Review weekly gig worker milestones and delivery metrics',
        dueDate: DateTime(now.year, now.month, now.day, 14, 30),
        priority: TaskPriority.medium,
        isCompleted: false,
        createdAt: now,
      ),
      TaskModel(
        id: 'sample_3',
        userId: userId,
        title: 'Call Charlotte',
        description: 'Discuss delivery schedule and route optimization',
        dueDate: DateTime(now.year, now.month, now.day + 1, 11, 0),
        priority: TaskPriority.high,
        isCompleted: false,
        createdAt: now,
      ),
      TaskModel(
        id: 'sample_4',
        userId: userId,
        title: 'Submit exercise 3.1',
        description: 'Upload client delivery confirmation and receipts',
        dueDate: DateTime(now.year, now.month, now.day + 1, 17, 0),
        priority: TaskPriority.low,
        isCompleted: false,
        createdAt: now,
      ),
      TaskModel(
        id: 'sample_5',
        userId: userId,
        title: 'Prepare A/B test',
        description: 'Compare dispatch latency across delivery zones',
        dueDate: DateTime(now.year, now.month, now.day + 3, 16, 0),
        priority: TaskPriority.high,
        isCompleted: false,
        createdAt: now,
      ),
      TaskModel(
        id: 'sample_6',
        userId: userId,
        title: 'Submit exercise 3.2',
        description: 'Finalize weekly mileage report and fuel reimbursements',
        dueDate: DateTime(now.year, now.month, now.day + 4, 18, 0),
        priority: TaskPriority.medium,
        isCompleted: false,
        createdAt: now,
      ),
    ];
  }
}

