import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/task_state.dart';

class FilterChipsBar extends StatelessWidget {
  final TaskStatusFilter selectedStatus;
  final TaskPriorityFilter selectedPriority;
  final ValueChanged<TaskStatusFilter> onStatusSelected;
  final ValueChanged<TaskPriorityFilter> onPrioritySelected;
  final int allCount;
  final int incompleteCount;
  final int completedCount;

  const FilterChipsBar({
    super.key,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.onStatusSelected,
    required this.onPrioritySelected,
    this.allCount = 0,
    this.incompleteCount = 0,
    this.completedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Status Segmented Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p20),
          child: Container(
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // Slate-100
              borderRadius: BorderRadius.circular(AppDimensions.rFull),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Row(
              children: TaskStatusFilter.values.map((status) {
                final isSelected = selectedStatus == status;
                int count = allCount;
                if (status == TaskStatusFilter.incomplete) count = incompleteCount;
                if (status == TaskStatusFilter.completed) count = completedCount;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onStatusSelected(status),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppDimensions.rFull),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  status.label,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                if (count > 0) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withValues(alpha: 0.12)
                                          : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(AppDimensions.rFull),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.p12),

        // 2. Priority Filter Pills
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p20),
            children: TaskPriorityFilter.values.map((priority) {
              final isSelected = selectedPriority == priority;
              Color activeColor = AppColors.primary;
              Color activeBg = AppColors.primary.withValues(alpha: 0.1);
              if (priority == TaskPriorityFilter.high) {
                activeColor = AppColors.priorityHigh;
                activeBg = AppColors.priorityHighBg;
              } else if (priority == TaskPriorityFilter.medium) {
                activeColor = AppColors.priorityMedium;
                activeBg = AppColors.priorityMediumBg;
              } else if (priority == TaskPriorityFilter.low) {
                activeColor = AppColors.priorityLow;
                activeBg = AppColors.priorityLowBg;
              }

              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.p8),
                child: InkWell(
                  onTap: () => onPrioritySelected(priority),
                  borderRadius: BorderRadius.circular(AppDimensions.rFull),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? activeBg : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.rFull),
                      border: Border.all(
                        color: isSelected ? activeColor : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (priority != TaskPriorityFilter.all) ...[
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: activeColor,
                              shape: BoxShape.circle,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: activeColor.withValues(alpha: 0.6),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          priority.label,
                          style: TextStyle(
                            color: isSelected
                                ? activeColor
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
