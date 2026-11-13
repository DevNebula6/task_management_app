import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/features/tasks/domain/entities/task_entity.dart';
import 'package:task_management_app/features/tasks/presentation/widgets/task_tile.dart';

void main() {
  testWidgets('TaskTile renders title, priority pill and toggles checkbox', (tester) async {
    final task = TaskEntity(
      id: 'task_1',
      userId: 'user_1',
      title: 'Pack Amazon Orders',
      description: 'Check item barcode and pack',
      dueDate: DateTime.now().add(const Duration(hours: 3)),
      priority: TaskPriority.high,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    bool toggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskTile(
            task: task,
            onToggleStatus: (val) => toggled = val,
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Pack Amazon Orders'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);

    // Tap circular checkbox
    await tester.tap(find.byKey(Key('task_checkbox_${task.id}')));
    await tester.pumpAndSettle();
    expect(toggled, isTrue);
  });
}
