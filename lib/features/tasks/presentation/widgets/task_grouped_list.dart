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
  final VoidCallback? onResetFilters;

  const TaskGroupedList({
    super.key,
    required this.tasks,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
    this.onResetFilters,
  });

  Color _getSectionColor(String section) {
    switch (section) {
      case 'Overdue':
        return AppColors.error;
      case 'Today':
        return AppColors.primary;
      case 'Tomorrow':
        return AppColors.accent;
      case 'This week':
        return const Color(0xFF0284C7); // Sky-600
      default:
        return AppColors.textSecondary;
    }
  }

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
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.primaryLight.withValues(alpha: 0.04),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.p20),
              const Text(
                AppStrings.emptyTasksTitle,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AppDimensions.p8),
              const Text(
                AppStrings.emptyTasksSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              if (onResetFilters != null) ...[
                const SizedBox(height: AppDimensions.p20),
                OutlinedButton.icon(
                  onPressed: onResetFilters,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reset All Filters'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.rFull),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
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

    final activeSections =
        sectionOrder.where((s) => grouped.containsKey(s) && grouped[s]!.isNotEmpty).toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.p20,
        AppDimensions.p8,
        AppDimensions.p20,
        100, // Bottom padding for docked FAB
      ),
      itemCount: activeSections.length,
      itemBuilder: (context, index) {
        final section = activeSections[index];
        final sectionTasks = grouped[section]!;
        final sectionColor = _getSectionColor(section);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: AppDimensions.p16,
                bottom: AppDimensions.p12,
                left: AppDimensions.p4,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: sectionColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.p8),
                  Text(
                    section.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: section == 'Overdue'
                          ? AppColors.error
                          : AppColors.textPrimary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.p8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: section == 'Overdue'
                          ? AppColors.priorityHighBg
                          : sectionColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.rFull),
                      border: Border.all(
                        color: sectionColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${sectionTasks.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: sectionColor,
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
