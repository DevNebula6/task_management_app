import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/filter_chips_bar.dart';
import '../widgets/task_calendar_view.dart';
import '../widgets/task_form_sheet.dart';
import '../widgets/task_grouped_list.dart';
import '../widgets/tasks_header.dart';

class HomePage extends StatefulWidget {
  final UserEntity user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0: Tasks List, 1: Calendar View

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(TaskSubscriptionRequested(widget.user.id));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<TaskBloc>().add(TaskFilterChanged(searchQuery: query));
  }

  void _openAddTaskSheet({DateTime? initialDate}) {
    TaskFormSheet.show(
      context: context,
      userId: widget.user.id,
      initialDate: initialDate,
      onSubmit: (newTask) {
        context.read<TaskBloc>().add(TaskCreated(newTask));
        AppSnackBar.showSuccess(context, 'Task created successfully');
      },
    );
  }

  void _openEditTaskSheet(TaskEntity task) {
    TaskFormSheet.show(
      context: context,
      userId: widget.user.id,
      taskToEdit: task,
      onSubmit: (updatedTask) {
        context.read<TaskBloc>().add(TaskUpdated(updatedTask));
        AppSnackBar.showSuccess(context, 'Task updated successfully');
      },
    );
  }

  void _deleteTask(TaskEntity task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r20),
        ),
        title: const Text(
          AppStrings.deleteTask,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(AppStrings.deleteTaskPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(90, 42),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<TaskBloc>().add(
                    TaskDeleted(taskId: task.id, userId: widget.user.id),
                  );
              AppSnackBar.showInfo(context, 'Task deleted');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskOperationFailure) {
            AppSnackBar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final int totalTasks = state is TaskLoaded
              ? state.allTasks.length
              : state is TaskOperationFailure
                  ? state.fallbackTasks.length
                  : 0;
          final int completedTasks = state is TaskLoaded
              ? state.allTasks.where((t) => t.isCompleted).length
              : state is TaskOperationFailure
                  ? state.fallbackTasks.where((t) => t.isCompleted).length
                  : 0;
          final int pendingTasks = state is TaskLoaded
              ? state.allTasks.where((t) => !t.isCompleted).length
              : state is TaskOperationFailure
                  ? state.fallbackTasks.where((t) => !t.isCompleted).length
                  : 0;

          return Column(
            children: [
              // 1. Curved Indigo Header (Reference2.png)
              TasksHeader(
                userName: widget.user.displayName ?? widget.user.email,
                searchController: _searchController,
                onSearchChanged: _onSearchChanged,
                totalTasks: totalTasks,
                completedTasks: completedTasks,
                pendingTasks: pendingTasks,
                onLogout: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
              ),
              const SizedBox(height: AppDimensions.p16),

              // 2. Body based on selected tab (List or Calendar)
              if (_selectedTab == 0) ...[
                if (state is TaskLoaded)
                  FilterChipsBar(
                    selectedStatus: state.statusFilter,
                    selectedPriority: state.priorityFilter,
                    allCount: totalTasks,
                    incompleteCount: pendingTasks,
                    completedCount: completedTasks,
                    onStatusSelected: (status) {
                      context.read<TaskBloc>().add(
                            TaskFilterChanged(statusFilter: status),
                          );
                    },
                    onPrioritySelected: (priority) {
                      context.read<TaskBloc>().add(
                            TaskFilterChanged(priorityFilter: priority),
                          );
                    },
                  ),
                const SizedBox(height: AppDimensions.p8),
                Expanded(
                  child: _buildTaskListBody(state),
                ),
              ] else ...[
                Expanded(
                  child: _buildCalendarBody(state),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTaskSheet(),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.list_alt_rounded,
                color: _selectedTab == 0 ? AppColors.primary : AppColors.textMuted,
                size: 26,
              ),
              onPressed: () => setState(() => _selectedTab = 0),
              tooltip: 'Tasks List',
            ),
            const SizedBox(width: 48), // Gap for docked FAB
            IconButton(
              icon: Icon(
                Icons.calendar_month_rounded,
                color: _selectedTab == 1 ? AppColors.primary : AppColors.textMuted,
                size: 26,
              ),
              onPressed: () => setState(() => _selectedTab = 1),
              tooltip: 'Calendar View',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListBody(TaskState state) {
    if (state is TaskLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final List<TaskEntity> tasksToDisplay;
    final TaskStatusFilter statusFilter;
    final TaskPriorityFilter priorityFilter;

    if (state is TaskLoaded) {
      tasksToDisplay = state.filteredTasks;
      statusFilter = state.statusFilter;
      priorityFilter = state.priorityFilter;
    } else if (state is TaskOperationFailure && state.fallbackTasks.isNotEmpty) {
      tasksToDisplay = state.fallbackTasks;
      statusFilter = TaskStatusFilter.all;
      priorityFilter = TaskPriorityFilter.all;
    } else {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: TaskGroupedList(
        key: ValueKey('${statusFilter}_${priorityFilter}_${tasksToDisplay.length}'),
        tasks: tasksToDisplay,
        onResetFilters: () {
          _searchController.clear();
          context.read<TaskBloc>().add(
                const TaskFilterChanged(
                  statusFilter: TaskStatusFilter.all,
                  priorityFilter: TaskPriorityFilter.all,
                  searchQuery: '',
                ),
              );
        },
        onToggleStatus: (task) {
          context.read<TaskBloc>().add(
                TaskStatusToggled(
                  taskId: task.id,
                  userId: widget.user.id,
                  isCompleted: !task.isCompleted,
                ),
              );
        },
        onEdit: _openEditTaskSheet,
        onDelete: _deleteTask,
      ),
    );
  }

  Widget _buildCalendarBody(TaskState state) {
    if (state is TaskLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final List<TaskEntity> allTasks = state is TaskLoaded
        ? state.allTasks
        : state is TaskOperationFailure
            ? state.fallbackTasks
            : [];

    return TaskCalendarView(
      allTasks: allTasks,
      onToggleStatus: (task) {
        context.read<TaskBloc>().add(
              TaskStatusToggled(
                taskId: task.id,
                userId: widget.user.id,
                isCompleted: !task.isCompleted,
              ),
            );
      },
      onEdit: _openEditTaskSheet,
      onDelete: _deleteTask,
      onAddTaskForDate: (date) {
        _openAddTaskSheet(initialDate: date);
      },
    );
  }
}

