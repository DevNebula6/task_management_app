import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> getTasksStream(String userId);
  Future<List<TaskModel>> getTasks(String userId);
  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId, String userId);
  Future<void> toggleTaskStatus(String taskId, String userId, bool isCompleted);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> _tasksCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('tasks');
  }

  @override
  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _tasksCollection(userId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    try {
      final snapshot = await _tasksCollection(userId)
          .orderBy('dueDate', descending: false)
          .get();
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to fetch tasks from Firestore: $e');
    }
  }

  @override
  Future<void> createTask(TaskModel task) async {
    try {
      await _tasksCollection(task.userId)
          .doc(task.id)
          .set(task.toFirestoreMap(), SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Failed to create task in Firestore: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _tasksCollection(task.userId)
          .doc(task.id)
          .set(task.toFirestoreMap(), SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Failed to update task in Firestore: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId, String userId) async {
    try {
      await _tasksCollection(userId).doc(taskId).delete();
    } catch (e) {
      throw ServerException('Failed to delete task in Firestore: $e');
    }
  }

  @override
  Future<void> toggleTaskStatus(String taskId, String userId, bool isCompleted) async {
    try {
      await _tasksCollection(userId).doc(taskId).update({
        'isCompleted': isCompleted,
      });
    } catch (e) {
      throw ServerException('Failed to toggle task status in Firestore: $e');
    }
  }
}

