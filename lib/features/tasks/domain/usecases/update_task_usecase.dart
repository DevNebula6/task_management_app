import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;
  const UpdateTaskUseCase(this.repository);

  Future<Either<Failure, void>> call(TaskEntity task) {
    return repository.updateTask(task);
  }
}
