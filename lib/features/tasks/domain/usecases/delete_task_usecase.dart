import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;
  const DeleteTaskUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String taskId,
    required String userId,
  }) {
    return repository.deleteTask(taskId, userId);
  }
}
