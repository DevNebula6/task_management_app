import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/features/tasks/data/models/task_model.dart';
import 'package:task_management_app/features/tasks/domain/entities/task_entity.dart';

void main() {
  group('Task Layer Unit Tests', () {
    final now = DateTime.now();
    final task = TaskModel(
      id: 'task_001',
      userId: 'user_123',
      title: 'Submit Gig Documentation',
      description: 'Upload the invoices and mileage log',
      dueDate: now.add(const Duration(hours: 4)),
      priority: TaskPriority.high,
      isCompleted: false,
      createdAt: now,
    );

    test('TaskModel correctly serializes to and from Map', () {
      final map = task.toMap();
      expect(map['id'], 'task_001');
      expect(map['userId'], 'user_123');
      expect(map['title'], 'Submit Gig Documentation');
      expect(map['priority'], 'high');
      expect(map['isCompleted'], false);

      final deserialized = TaskModel.fromMap(map);
      expect(deserialized.id, task.id);
      expect(deserialized.priority, TaskPriority.high);
      expect(deserialized.isCompleted, isFalse);
    });

    test('TaskPriority.fromString parses properly with default fallback', () {
      expect(TaskPriority.fromString('high'), TaskPriority.high);
      expect(TaskPriority.fromString('MEDIUM'), TaskPriority.medium);
      expect(TaskPriority.fromString('low'), TaskPriority.low);
      expect(TaskPriority.fromString('invalid'), TaskPriority.low);
    });

    test('Tasks sorting by dueDate earliest to latest', () {
      final t1 = task.copyWith(
        id: '1',
        dueDate: now.add(const Duration(days: 2)),
      );
      final t2 = task.copyWith(
        id: '2',
        dueDate: now.add(const Duration(days: 1)),
      );
      final t3 = task.copyWith(
        id: '3',
        dueDate: now.add(const Duration(hours: 2)),
      );

      final list = [t1, t2, t3]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      expect(list.map((e) => e.id).toList(), ['3', '2', '1']);
    });
  });
}
