import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/task_entity.dart';
import 'task_tile.dart';

class TaskGroupedList extends StatelessWidget {
  final List<TaskEntity> tasks;
  final ValueChanged<TaskEntity> onToggleStatus;
  final ValueChanged<TaskEntity> onEdit;
  final ValueChanged<TaskEntity> onDelete;

  const TaskGroupedList({
    super.key,
    required this.tasks,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.p16),
              Text(
                AppStrings.emptyTasksTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.p8),
              Text(
                AppStrings.emptyTasksSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group tasks by section
    final Map<String, List<TaskEntity>> grouped = {};
    const sectionOrder = ['Overdue', 'Today', 'Tomorrow', 'This week', 'Later'];

    for (final task in tasks) {
      final section = DateFormatter.getSectionName(task.dueDate);
      grouped.putIfAbsent(section, () => []).add(task);
    }

    final activeSections = sectionOrder.where((s) => grouped.containsKey(s) && grouped[s]!.isNotEmpty).toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.p20,
        AppDimensions.p12,
        AppDimensions.p20,
        90, // Bottom padding for FAB
      ),
      itemCount: activeSections.length,
      itemBuilder: (context, index) {
        final section = activeSections[index];
        final sectionTasks = grouped[section]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: AppDimensions.p12,
                bottom: AppDimensions.p12,
                left: AppDimensions.p4,
              ),
              child: Row(
                children: [
                  Text(
                    section,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: section == 'Overdue'
                          ? AppColors.error
                          : AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.p8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: section == 'Overdue'
                          ? AppColors.priorityHighBg
                          : AppColors.border.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppDimensions.rFull),
                    ),
                    child: Text(
                      '${sectionTasks.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: section == 'Overdue'
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...sectionTasks.map((task) => TaskTile(
                  task: task,
                  onToggleStatus: (_) => onToggleStatus(task),
                  onEdit: () => onEdit(task),
                  onDelete: () => onDelete(task),
                )),
          ],
        );
      },
    );
  }
}
