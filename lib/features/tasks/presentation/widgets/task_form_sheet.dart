import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/task_entity.dart';

class TaskFormSheet extends StatefulWidget {
  final String userId;
  final TaskEntity? taskToEdit;
  final ValueChanged<TaskEntity> onSubmit;

  const TaskFormSheet({
    super.key,
    required this.userId,
    this.taskToEdit,
    required this.onSubmit,
  });

  static Future<void> show({
    required BuildContext context,
    required String userId,
    TaskEntity? taskToEdit,
    required ValueChanged<TaskEntity> onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormSheet(
        userId: userId,
        taskToEdit: taskToEdit,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late DateTime _selectedDueDate;
  late TimeOfDay _selectedTime;
  late TaskPriority _selectedPriority;

  bool get isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _selectedDueDate = task?.dueDate ?? DateTime.now();
    _selectedTime = task != null
        ? TimeOfDay(hour: task.dueDate.hour, minute: task.dueDate.minute)
        : TimeOfDay.now();
    _selectedPriority = task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _applyQuickPreset(Duration offset, int hour, int minute) {
    HapticFeedback.selectionClick();
    final target = DateTime.now().add(offset);
    setState(() {
      _selectedDueDate = DateTime(target.year, target.month, target.day, hour, minute);
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedDueDate = DateTime(
          _selectedDueDate.year,
          _selectedDueDate.month,
          _selectedDueDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      final combinedDateTime = DateTime(
        _selectedDueDate.year,
        _selectedDueDate.month,
        _selectedDueDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final task = isEditing
          ? widget.taskToEdit!.copyWith(
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              dueDate: combinedDateTime,
              priority: _selectedPriority,
            )
          : TaskEntity(
              id: const Uuid().v4(),
              userId: widget.userId,
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              dueDate: combinedDateTime,
              priority: _selectedPriority,
              isCompleted: false,
              createdAt: DateTime.now(),
            );

      widget.onSubmit(task);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.p24,
        AppDimensions.p16,
        AppDimensions.p24,
        AppDimensions.p24 + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet handle bar
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(AppDimensions.rFull),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.p20),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimensions.r12),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit_note_rounded : Icons.add_task_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.p12),
                      Text(
                        isEditing ? AppStrings.editTask : AppStrings.newTask,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.p20),

              // Task Title Input
              CustomTextField(
                controller: _titleController,
                label: AppStrings.taskTitle,
                hint: 'e.g. Deliver Package #408 or Client Pickup',
                prefixIcon: Icons.title_rounded,
                validator: (val) => Validators.validateRequired(val, 'Title'),
              ),
              const SizedBox(height: AppDimensions.p16),

              // Description Input
              CustomTextField(
                controller: _descController,
                label: AppStrings.taskDescription,
                hint: 'Customer delivery notes, pickup location, or contacts...',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: AppDimensions.p20),

              // Quick Time Presets
              const Text(
                'Quick Due Presets',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.p8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      label: const Text('In 2 Hours'),
                      avatar: const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.primary),
                      onPressed: () {
                        final now = DateTime.now().add(const Duration(hours: 2));
                        _applyQuickPreset(const Duration(hours: 2), now.hour, now.minute);
                      },
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.rFull),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.p8),
                    ActionChip(
                      label: const Text('Today 6 PM'),
                      onPressed: () => _applyQuickPreset(Duration.zero, 18, 0),
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.rFull),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.p8),
                    ActionChip(
                      label: const Text('Tomorrow 10 AM'),
                      onPressed: () => _applyQuickPreset(const Duration(days: 1), 10, 0),
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.rFull),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.p16),

              // Due Date & Time Selectors
              const Text(
                AppStrings.dueDate,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.p8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(AppDimensions.r16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.p16,
                          vertical: AppDimensions.p14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppDimensions.r16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppDimensions.p8),
                            Expanded(
                              child: Text(
                                DateFormatter.formatShort(_selectedDueDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.p12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(AppDimensions.r16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.p16,
                          vertical: AppDimensions.p14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppDimensions.r16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppDimensions.p8),
                            Expanded(
                              child: Text(
                                _selectedTime.format(context),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.p20),

              // Priority Selector Cards
              const Text(
                AppStrings.priority,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.p8),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: priority != TaskPriority.values.last ? 8.0 : 0,
                      ),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedPriority = priority);
                        },
                        borderRadius: BorderRadius.circular(AppDimensions.r16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? priority.backgroundColor
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(AppDimensions.r16),
                            border: Border.all(
                              color: isSelected
                                  ? priority.color
                                  : AppColors.border,
                              width: isSelected ? 1.8 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: priority.color.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                priority == TaskPriority.high
                                    ? Icons.local_fire_department_rounded
                                    : priority == TaskPriority.medium
                                        ? Icons.bolt_rounded
                                        : Icons.spa_rounded,
                                color: priority.color,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                priority.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? priority.color
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.p28),

              // Submit Button
              CustomButton(
                text: isEditing ? AppStrings.updateTask : AppStrings.saveTask,
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
