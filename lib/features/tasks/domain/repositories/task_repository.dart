import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> getTasksStream(String userId);
  Future<Either<Failure, List<TaskEntity>>> getTasks(String userId);
  Future<Either<Failure, void>> createTask(TaskEntity task);
  Future<Either<Failure, void>> updateTask(TaskEntity task);
  Future<Either<Failure, void>> deleteTask(String taskId, String userId);
  Future<Either<Failure, void>> toggleTaskStatus(String taskId, String userId, bool isCompleted);
}

