import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/toggle_task_status_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final ToggleTaskStatusUseCase toggleTaskStatusUseCase;

  StreamSubscription<List<TaskEntity>>? _tasksSubscription;

  TaskBloc({
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.toggleTaskStatusUseCase,
  }) : super(const TaskInitial()) {
    on<TaskSubscriptionRequested>(_onSubscriptionRequested);
    on<TaskCreated>(_onTaskCreated);
    on<TaskUpdated>(_onTaskUpdated);
    on<TaskDeleted>(_onTaskDeleted);
    on<TaskStatusToggled>(_onTaskStatusToggled);
    on<TaskFilterChanged>(_onTaskFilterChanged);
  }

  Future<void> _onSubscriptionRequested(
    TaskSubscriptionRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    await _tasksSubscription?.cancel();

    await emit.forEach<List<TaskEntity>>(
      getTasksUseCase.stream(event.userId),
      onData: (tasks) {
        final sortedTasks = List<TaskEntity>.from(tasks)
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

        final currentStatus = state is TaskLoaded
            ? (state as TaskLoaded).statusFilter
            : TaskStatusFilter.all;
        final currentPriority = state is TaskLoaded
            ? (state as TaskLoaded).priorityFilter
            : TaskPriorityFilter.all;
        final currentSearch =
            state is TaskLoaded ? (state as TaskLoaded).searchQuery : '';

        final filtered = _applyFilters(
          sortedTasks,
          currentStatus,
          currentPriority,
          currentSearch,
        );

        return TaskLoaded(
          allTasks: sortedTasks,
          filteredTasks: filtered,
          statusFilter: currentStatus,
          priorityFilter: currentPriority,
          searchQuery: currentSearch,
        );
      },
      onError: (error, stackTrace) =>
          TaskOperationFailure('Failed to load tasks: $error'),
    );
  }

  Future<void> _onTaskCreated(
    TaskCreated event,
    Emitter<TaskState> emit,
  ) async {
    final result = await createTaskUseCase(event.task);
    result.fold(
      (failure) => emit(TaskOperationFailure(failure.message)),
      (_) {},
    );
  }

  Future<void> _onTaskUpdated(
    TaskUpdated event,
    Emitter<TaskState> emit,
  ) async {
    final result = await updateTaskUseCase(event.task);
    result.fold(
      (failure) => emit(TaskOperationFailure(failure.message)),
      (_) {},
    );
  }

  Future<void> _onTaskDeleted(
    TaskDeleted event,
    Emitter<TaskState> emit,
  ) async {
    final result = await deleteTaskUseCase(
      taskId: event.taskId,
      userId: event.userId,
    );
    result.fold(
      (failure) => emit(TaskOperationFailure(failure.message)),
      (_) {},
    );
  }

  Future<void> _onTaskStatusToggled(
    TaskStatusToggled event,
    Emitter<TaskState> emit,
  ) async {
    final result = await toggleTaskStatusUseCase(
      taskId: event.taskId,
      userId: event.userId,
      isCompleted: event.isCompleted,
    );
    result.fold(
      (failure) => emit(TaskOperationFailure(failure.message)),
      (_) {},
    );
  }

  void _onTaskFilterChanged(
    TaskFilterChanged event,
    Emitter<TaskState> emit,
  ) {
    if (state is TaskLoaded) {
      final current = state as TaskLoaded;
      final newStatus = event.statusFilter ?? current.statusFilter;
      final newPriority = event.priorityFilter ?? current.priorityFilter;
      final newSearch = event.searchQuery ?? current.searchQuery;

      final filtered = _applyFilters(
        current.allTasks,
        newStatus,
        newPriority,
        newSearch,
      );

      emit(current.copyWith(
        filteredTasks: filtered,
        statusFilter: newStatus,
        priorityFilter: newPriority,
        searchQuery: newSearch,
      ));
    }
  }

  List<TaskEntity> _applyFilters(
    List<TaskEntity> tasks,
    TaskStatusFilter status,
    TaskPriorityFilter priority,
    String search,
  ) {
    return tasks.where((task) {
      // Status filter
      if (status == TaskStatusFilter.completed && !task.isCompleted) {
        return false;
      }
      if (status == TaskStatusFilter.incomplete && task.isCompleted) {
        return false;
      }

      // Priority filter
      if (priority != TaskPriorityFilter.all) {
        if (task.priority.name != priority.name) {
          return false;
        }
      }

      // Search query filter
      if (search.trim().isNotEmpty) {
        final query = search.toLowerCase().trim();
        final matchTitle = task.title.toLowerCase().contains(query);
        final matchDesc = task.description.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
