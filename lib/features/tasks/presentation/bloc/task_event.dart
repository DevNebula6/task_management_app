import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import 'task_state.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TaskSubscriptionRequested extends TaskEvent {
  final String userId;

  const TaskSubscriptionRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class TaskCreated extends TaskEvent {
  final TaskEntity task;

  const TaskCreated(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskUpdated extends TaskEvent {
  final TaskEntity task;

  const TaskUpdated(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskDeleted extends TaskEvent {
  final String taskId;
  final String userId;

  const TaskDeleted({required this.taskId, required this.userId});

  @override
  List<Object?> get props => [taskId, userId];
}

class TaskStatusToggled extends TaskEvent {
  final String taskId;
  final String userId;
  final bool isCompleted;

  const TaskStatusToggled({
    required this.taskId,
    required this.userId,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [taskId, userId, isCompleted];
}

class TaskFilterChanged extends TaskEvent {
  final TaskStatusFilter? statusFilter;
  final TaskPriorityFilter? priorityFilter;
  final String? searchQuery;

  const TaskFilterChanged({
    this.statusFilter,
    this.priorityFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [statusFilter, priorityFilter, searchQuery];
}

