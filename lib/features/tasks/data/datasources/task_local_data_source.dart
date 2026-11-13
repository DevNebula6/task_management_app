import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<void> cacheTasks(List<TaskModel> tasks);
  List<TaskModel> getCachedTasks({String? userId});
  Future<void> cacheTask(TaskModel task);
  Future<void> removeTask(String taskId);
  Future<void> toggleTaskStatus(String taskId, bool isCompleted);
  Stream<List<TaskModel>> watchTasks({String? userId});
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<dynamic> tasksBox;

  TaskLocalDataSourceImpl({required this.tasksBox});

  String _getKey(String taskId) => 'task_$taskId';

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    try {
      final entries = <String, String>{};
      for (final task in tasks) {
        entries[_getKey(task.id)] = jsonEncode(task.toMap());
      }
      await tasksBox.putAll(entries);
    } catch (e) {
      throw CacheException('Failed to cache tasks in Hive: $e');
    }
  }

  @override
  List<TaskModel> getCachedTasks({String? userId}) {
    try {
      final List<TaskModel> list = [];
      for (final key in tasksBox.keys) {
        if (key.toString().startsWith('task_')) {
          final raw = tasksBox.get(key);
          if (raw != null) {
            final map = jsonDecode(raw as String) as Map<String, dynamic>;
            final model = TaskModel.fromMap(map);
            if (userId == null || model.userId == userId || model.userId.isEmpty) {
              list.add(model);
            }
          }
        }
      }
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return list;
    } catch (e) {
      throw CacheException('Failed to retrieve tasks from Hive: $e');
    }
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    try {
      await tasksBox.put(_getKey(task.id), jsonEncode(task.toMap()));
    } catch (e) {
      throw CacheException('Failed to write task to Hive: $e');
    }
  }

  @override
  Future<void> removeTask(String taskId) async {
    try {
      await tasksBox.delete(_getKey(taskId));
    } catch (e) {
      throw CacheException('Failed to delete task from Hive: $e');
    }
  }

  @override
  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    try {
      final key = _getKey(taskId);
      final raw = tasksBox.get(key);
      if (raw != null) {
        final map = jsonDecode(raw as String) as Map<String, dynamic>;
        map['isCompleted'] = isCompleted;
        await tasksBox.put(key, jsonEncode(map));
      }
    } catch (e) {
      throw CacheException('Failed to update task status in Hive: $e');
    }
  }

  @override
  Stream<List<TaskModel>> watchTasks({String? userId}) {
    return tasksBox.watch().map((_) => getCachedTasks(userId: userId));
  }
}

