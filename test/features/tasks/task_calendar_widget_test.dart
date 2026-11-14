import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/core/theme/app_theme.dart';
import 'package:task_management_app/features/tasks/domain/entities/task_entity.dart';
import 'package:task_management_app/features/tasks/presentation/widgets/task_calendar_view.dart';

void main() {
  testWidgets('TaskCalendarView renders date timeline and filters tasks by date',
      (tester) async {
    final now = DateTime.now();
    final todayTask = TaskEntity(
      id: 'task_today',
      userId: 'user_1',
      title: 'Deliver Priority Medical Kit',
      description: 'Urgent hospital delivery',
      dueDate: DateTime(now.year, now.month, now.day, 10, 0),
      priority: TaskPriority.high,
      isCompleted: false,
      createdAt: now,
    );

    final tomorrowTask = TaskEntity(
      id: 'task_tomorrow',
      userId: 'user_1',
      title: 'Warehouse Restock',
      description: 'Morning pickup',
      dueDate: DateTime(now.year, now.month, now.day + 1, 9, 0),
      priority: TaskPriority.medium,
      isCompleted: false,
      createdAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: TaskCalendarView(
            allTasks: [todayTask, tomorrowTask],
            onToggleStatus: (_) {},
            onEdit: (_) {},
            onDelete: (_) {},
            onAddTaskForDate: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify today's task is visible on initial load
    expect(find.text('Deliver Priority Medical Kit'), findsOneWidget);
    expect(find.text('Warehouse Restock'), findsNothing);

    // Tap tomorrow's date chip
    final tomorrowDayNumber = (now.day + 1).toString();
    final tomorrowChip = find.text(tomorrowDayNumber).first;
    await tester.tap(tomorrowChip);
    await tester.pumpAndSettle();

    // Now tomorrow's task should be displayed
    expect(find.text('Warehouse Restock'), findsOneWidget);
    expect(find.text('Deliver Priority Medical Kit'), findsNothing);
  });
}
