import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // 1. External & Storage
  await Hive.initFlutter();
  final tasksBox = await Hive.openBox<dynamic>('tasks_box');
  final userBox = await Hive.openBox<dynamic>('user_box');

  sl.registerLazySingleton<Box<dynamic>>(() => tasksBox, instanceName: 'tasksBox');
  sl.registerLazySingleton<Box<dynamic>>(() => userBox, instanceName: 'userBox');

  // Firebase
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Features will be registered in their respective phases
}
