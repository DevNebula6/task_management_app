import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

enum TaskStatusFilter {
  all('All'),
  incomplete('Incomplete'),
  completed('Completed');

  final String label;
  const TaskStatusFilter(this.label);
}

enum TaskPriorityFilter {
  all('All'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;
  const TaskPriorityFilter(this.label);
}

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final List<TaskEntity> allTasks;
  final List<TaskEntity> filteredTasks;
  final TaskStatusFilter statusFilter;
  final TaskPriorityFilter priorityFilter;
  final String searchQuery;

  const TaskLoaded({
    required this.allTasks,
    required this.filteredTasks,
    this.statusFilter = TaskStatusFilter.all,
    this.priorityFilter = TaskPriorityFilter.all,
    this.searchQuery = '',
  });

  TaskLoaded copyWith({
    List<TaskEntity>? allTasks,
    List<TaskEntity>? filteredTasks,
    TaskStatusFilter? statusFilter,
    TaskPriorityFilter? priorityFilter,
    String? searchQuery,
  }) {
    return TaskLoaded(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get isFilteringActive =>
      statusFilter != TaskStatusFilter.all ||
      priorityFilter != TaskPriorityFilter.all ||
      searchQuery.isNotEmpty;

  int get completedCount => allTasks.where((t) => t.isCompleted).length;
  int get pendingCount => allTasks.where((t) => !t.isCompleted).length;

  @override
  List<Object?> get props => [
        allTasks,
        filteredTasks,
        statusFilter,
        priorityFilter,
        searchQuery,
      ];
}

class TaskOperationFailure extends TaskState {
  final String message;

  const TaskOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

