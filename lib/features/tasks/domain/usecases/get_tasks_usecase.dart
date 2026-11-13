import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;
  const GetTasksUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call(String userId) {
    return repository.getTasks(userId);
  }

  Stream<List<TaskEntity>> stream(String userId) {
    return repository.getTasksStream(userId);
  }
}
