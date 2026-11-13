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

  void _openAddTaskSheet() {
    TaskFormSheet.show(
      context: context,
      userId: widget.user.id,
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
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskOperationFailure) {
            AppSnackBar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // 1. Curved Indigo Header (Reference2.png)
              TasksHeader(
                userName: widget.user.displayName ?? widget.user.email,
                searchController: _searchController,
                onSearchChanged: _onSearchChanged,
                onLogout: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
              ),
              const SizedBox(height: AppDimensions.p16),

              // 2. Filter Bar
              if (state is TaskLoaded)
                FilterChipsBar(
                  selectedStatus: state.statusFilter,
                  selectedPriority: state.priorityFilter,
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

              // 3. Task Grouped List Body
              Expanded(
                child: _buildTaskListBody(state),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskSheet,
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
              icon: const Icon(Icons.list_alt_rounded, color: AppColors.primary),
              onPressed: () {},
              tooltip: 'Tasks',
            ),
            const SizedBox(width: 48), // Gap for docked FAB
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined, color: AppColors.textMuted),
              onPressed: () {
                AppSnackBar.showInfo(context, 'Calendar view coming in next update');
              },
              tooltip: 'Calendar',
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

    if (state is TaskLoaded) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: TaskGroupedList(
          key: ValueKey('${state.statusFilter}_${state.priorityFilter}_${state.filteredTasks.length}'),
          tasks: state.filteredTasks,
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

    return const SizedBox.shrink();
  }
}

