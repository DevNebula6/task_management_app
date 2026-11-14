import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/task_entity.dart';
import 'task_tile.dart';

class TaskCalendarView extends StatefulWidget {
  final List<TaskEntity> allTasks;
  final ValueChanged<TaskEntity> onToggleStatus;
  final ValueChanged<TaskEntity> onEdit;
  final ValueChanged<TaskEntity> onDelete;
  final ValueChanged<DateTime> onAddTaskForDate;

  const TaskCalendarView({
    super.key,
    required this.allTasks,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
    required this.onAddTaskForDate,
  });

  @override
  State<TaskCalendarView> createState() => _TaskCalendarViewState();
}

class _TaskCalendarViewState extends State<TaskCalendarView> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  final ScrollController _dateStripController = ScrollController();

  final DateFormat _monthFormat = DateFormat('MMMM yyyy');
  final DateFormat _dayOfWeekFormat = DateFormat('E');
  final DateFormat _fullDayFormat = DateFormat('EEEE, d MMMM');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(now.year, now.month, 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate(animated: false);
    });
  }

  @override
  void dispose() {
    _dateStripController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate({bool animated = true}) {
    final dayIndex = _selectedDate.day - 1;
    // Each date chip is 64px wide + 8px margin = 72px
    const itemExtent = 72.0;
    final offset = (dayIndex * itemExtent - 120.0).clamp(
      0.0,
      _dateStripController.hasClients
          ? _dateStripController.position.maxScrollExtent
          : 5000.0,
    );

    if (_dateStripController.hasClients) {
      if (animated) {
        _dateStripController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } else {
        _dateStripController.jumpTo(offset);
      }
    }
  }

  void _onDateSelected(DateTime date) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
    _scrollToSelectedDate();
  }

  void _changeMonth(int offset) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + offset,
        1,
      );
      // Select the first day or matching day in new month
      final daysInNewMonth = DateUtils.getDaysInMonth(
        _currentMonth.year,
        _currentMonth.month,
      );
      final newDay = _selectedDate.day.clamp(1, daysInNewMonth);
      _selectedDate = DateTime(
        _currentMonth.year,
        _currentMonth.month,
        newDay,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _jumpToToday() {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    setState(() {
      _currentMonth = DateTime(now.year, now.month, 1);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  List<DateTime> get _daysInMonth {
    final count = DateUtils.getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    return List.generate(
      count,
      (i) => DateTime(_currentMonth.year, _currentMonth.month, i + 1),
    );
  }

  List<TaskEntity> get _tasksForSelectedDate {
    return widget.allTasks.where((task) {
      return DateFormatter.isSameDay(task.dueDate, _selectedDate);
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  Map<int, List<TaskEntity>> get _tasksByDayOfMonth {
    final map = <int, List<TaskEntity>>{};
    for (final task in widget.allTasks) {
      if (task.dueDate.year == _currentMonth.year &&
          task.dueDate.month == _currentMonth.month) {
        map.putIfAbsent(task.dueDate.day, () => []).add(task);
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final tasksForDay = _tasksForSelectedDate;
    final completedCount = tasksForDay.where((t) => t.isCompleted).length;
    final totalCount = tasksForDay.length;
    final isSelectedDateToday = DateFormatter.isToday(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Month Navigation Header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.p20,
            AppDimensions.p12,
            AppDimensions.p20,
            AppDimensions.p8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        _monthFormat.format(_currentMonth),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.p8),
                    if (!isSelectedDateToday)
                      InkWell(
                        onTap: _jumpToToday,
                        borderRadius: BorderRadius.circular(AppDimensions.rFull),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.rFull),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.today_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Today',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  _buildMonthNavButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _changeMonth(-1),
                    tooltip: 'Previous month',
                  ),
                  const SizedBox(width: 6),
                  _buildMonthNavButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _changeMonth(1),
                    tooltip: 'Next month',
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Horizontal Date Strip Scroller
        SizedBox(
          height: 86,
          child: ListView.builder(
            controller: _dateStripController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16),
            itemCount: _daysInMonth.length,
            itemBuilder: (context, index) {
              final date = _daysInMonth[index];
              final isSelected = DateFormatter.isSameDay(date, _selectedDate);
              final isToday = DateFormatter.isToday(date);
              final dayTasks = _tasksByDayOfMonth[date.day] ?? [];
              final hasTasks = dayTasks.isNotEmpty;
              final hasHighPriority =
                  dayTasks.any((t) => t.priority == TaskPriority.high && !t.isCompleted);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: GestureDetector(
                  onTap: () => _onDateSelected(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: 62,
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.fabGradient : null,
                      color: isSelected
                          ? null
                          : isToday
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.r16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : isToday
                                ? AppColors.primary
                                : AppColors.border,
                        width: isToday && !isSelected ? 1.6 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dayOfWeekFormat.format(date).toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.85)
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Micro Task Indicators
                        SizedBox(
                          height: 6,
                          child: hasTasks
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? Colors.white
                                            : hasHighPriority
                                                ? AppColors.priorityHigh
                                                : AppColors.primary,
                                      ),
                                    ),
                                    if (dayTasks.length > 1) ...[
                                      const SizedBox(width: 3),
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? Colors.white.withValues(alpha: 0.7)
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.p12),

        // 3. Day Summary Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.p8),
                    Expanded(
                      child: Text(
                        _fullDayFormat.format(_selectedDate),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.p8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: totalCount > 0
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(AppDimensions.rFull),
                ),
                child: Text(
                  totalCount > 0
                      ? '$completedCount / $totalCount Done'
                      : 'No Tasks',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: totalCount > 0
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.p8),

        // 4. Tasks List for Selected Date
        Expanded(
          child: tasksForDay.isEmpty
              ? _buildEmptyDayState(context)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.p20,
                    AppDimensions.p8,
                    AppDimensions.p20,
                    100, // Bottom padding for docked FAB
                  ),
                  itemCount: tasksForDay.length,
                  itemBuilder: (context, index) {
                    final task = tasksForDay[index];
                    return TaskTile(
                      task: task,
                      onToggleStatus: (_) => widget.onToggleStatus(task),
                      onEdit: () => widget.onEdit(task),
                      onDelete: () => widget.onDelete(task),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMonthNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 20, color: AppColors.textPrimary),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildEmptyDayState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.p16),
            const Text(
              'No Tasks Scheduled',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.p8),
            Text(
              'You have no delivery tasks scheduled for ${DateFormat('d MMMM').format(_selectedDate)}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppDimensions.p20),
            ElevatedButton.icon(
              onPressed: () => widget.onAddTaskForDate(_selectedDate),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Plan for ${DateFormat('d MMM').format(_selectedDate)}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.rFull),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
