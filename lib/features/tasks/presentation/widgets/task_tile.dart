import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/task_entity.dart';

class TaskTile extends StatelessWidget {
  final TaskEntity task;
  final ValueChanged<bool> onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Icons.local_fire_department_rounded;
      case TaskPriority.medium:
        return Icons.bolt_rounded;
      case TaskPriority.low:
        return Icons.spa_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = DateFormatter.isOverdue(task.dueDate) && !task.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.p12),
      child: Slidable(
        key: ValueKey(task.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.38,
          children: [
            // Edit Action
            CustomSlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: Colors.transparent,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            // Delete Action (Reference2.png circular red button)
            CustomSlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.transparent,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.priorityHighBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.priorityHigh.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.priorityHigh.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.priorityHigh,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(AppDimensions.r20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(AppDimensions.p16),
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? const Color(0xFFFBFBFE)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.r20),
              border: Border.all(
                color: task.isCompleted
                    ? AppColors.border.withValues(alpha: 0.5)
                    : isOverdue
                        ? AppColors.priorityHighBorder
                        : AppColors.border,
                width: isOverdue ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: task.isCompleted
                      ? Colors.transparent
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Custom Interactive Circular Checkbox with Spring Animation
                GestureDetector(
                  key: Key('task_checkbox_${task.id}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onToggleStatus(!task.isCompleted);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: task.isCompleted
                            ? const LinearGradient(
                                colors: [
                                  AppColors.primaryLight,
                                  AppColors.primary,
                                ],
                              )
                            : null,
                        color: task.isCompleted ? null : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                        boxShadow: task.isCompleted
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 17,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.p16),

                // Task Title, Description & Due Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: AppColors.textMuted,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          task.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: task.isCompleted
                                ? AppColors.textMuted.withValues(alpha: 0.7)
                                : AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            isOverdue
                                ? Icons.warning_amber_rounded
                                : Icons.access_time_rounded,
                            size: 13,
                            color: isOverdue
                                ? AppColors.error
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              isOverdue
                                  ? 'Overdue • ${DateFormatter.formatShort(task.dueDate)}'
                                  : '${DateFormatter.formatShort(task.dueDate)} • ${DateFormatter.formatTime(task.dueDate)}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                                color: isOverdue
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.p12),

                // Priority Badge Pill with Icon (Reference2.png)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: task.priority.backgroundColor,
                    borderRadius: BorderRadius.circular(AppDimensions.rFull),
                    border: Border.all(
                      color: task.priority.color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPriorityIcon(task.priority),
                        size: 12,
                        color: task.priority.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.priority.label,
                        style: TextStyle(
                          color: task.priority.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
