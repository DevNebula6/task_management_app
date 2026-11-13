import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;
  const CreateTaskUseCase(this.repository);

  Future<Either<Failure, void>> call(TaskEntity task) {
    return repository.createTask(task);
  }
}

