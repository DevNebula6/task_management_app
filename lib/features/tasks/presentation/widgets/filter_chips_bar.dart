import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/task_state.dart';

class FilterChipsBar extends StatelessWidget {
  final TaskStatusFilter selectedStatus;
  final TaskPriorityFilter selectedPriority;
  final ValueChanged<TaskStatusFilter> onStatusSelected;
  final ValueChanged<TaskPriorityFilter> onPrioritySelected;

  const FilterChipsBar({
    super.key,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.onStatusSelected,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Filter Chips
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p20),
            children: TaskStatusFilter.values.map((status) {
              final isSelected = selectedStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.p8),
                child: FilterChip(
                  label: Text(status.label),
                  selected: isSelected,
                  onSelected: (_) => onStatusSelected(status),
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.rFull),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppDimensions.p8),

        // Priority Filter Chips
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p20),
            children: TaskPriorityFilter.values.map((priority) {
              final isSelected = selectedPriority == priority;
              Color chipColor = AppColors.primary;
              if (priority == TaskPriorityFilter.high) {
                chipColor = AppColors.priorityHigh;
              } else if (priority == TaskPriorityFilter.medium) {
                chipColor = AppColors.priorityMedium;
              } else if (priority == TaskPriorityFilter.low) {
                chipColor = AppColors.priorityLow;
              }

              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.p8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (priority != TaskPriorityFilter.all) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : chipColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(priority.label),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => onPrioritySelected(priority),
                  backgroundColor: AppColors.surface,
                  selectedColor: chipColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.rFull),
                    side: BorderSide(
                      color: isSelected ? chipColor : AppColors.border,
                      width: 1,
                    ),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
