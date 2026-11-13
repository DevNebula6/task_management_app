import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/task_repository.dart';

class ToggleTaskStatusUseCase {
  final TaskRepository repository;
  const ToggleTaskStatusUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String taskId,
    required String userId,
    required bool isCompleted,
  }) {
    return repository.toggleTaskStatus(taskId, userId, isCompleted);
  }
}
