import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/core/constants/app_colors.dart';
import 'package:task_management_app/core/constants/app_dimensions.dart';
import 'package:task_management_app/core/theme/app_theme.dart';
import 'package:task_management_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_management_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:task_management_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_management_app/features/auth/presentation/pages/login_page.dart';
import 'package:task_management_app/features/auth/presentation/pages/onboarding_page.dart';
import 'package:task_management_app/features/tasks/domain/entities/task_entity.dart';
import 'package:task_management_app/features/tasks/presentation/bloc/task_state.dart';
import 'package:task_management_app/features/tasks/presentation/widgets/filter_chips_bar.dart';
import 'package:task_management_app/features/tasks/presentation/widgets/task_calendar_view.dart';
import 'package:task_management_app/features/tasks/presentation/widgets/task_form_sheet.dart';
import 'package:task_management_app/features/tasks/presentation/widgets/task_grouped_list.dart';
import 'package:task_management_app/features/tasks/presentation/widgets/tasks_header.dart';

class FakeAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  FakeAuthBloc() : super(const AuthInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final now = DateTime.now();
  final sampleTasks = [
    TaskEntity(
      id: 'task_1',
      title: 'Schedule dentist appointment',
      description: 'Routine six-month checkup and cleaning at Dental Care Clinic.',
      dueDate: DateTime(now.year, now.month, now.day, 10, 0),
      priority: TaskPriority.low,
      isCompleted: false,
      userId: 'demo_user',
      createdAt: now,
    ),
    TaskEntity(
      id: 'task_2',
      title: 'Prepare team meeting',
      description: 'Review slides and organize client presentation agenda.',
      dueDate: DateTime(now.year, now.month, now.day, 14, 0),
      priority: TaskPriority.medium,
      isCompleted: true,
      userId: 'demo_user',
      createdAt: now,
    ),
    TaskEntity(
      id: 'task_3',
      title: 'Call Charlotte',
      description: 'Discuss Q4 gig performance metrics and shift assignments.',
      dueDate: DateTime(now.year, now.month, now.day + 1, 11, 30),
      priority: TaskPriority.high,
      isCompleted: false,
      userId: 'demo_user',
      createdAt: now,
    ),
    TaskEntity(
      id: 'task_4',
      title: 'Submit exercise 3.1',
      description: 'Upload sprint review documentation to WhatBytes portal.',
      dueDate: DateTime(now.year, now.month, now.day + 1, 16, 0),
      priority: TaskPriority.medium,
      isCompleted: false,
      userId: 'demo_user',
      createdAt: now,
    ),
    TaskEntity(
      id: 'task_5',
      title: 'Prepare A/R float',
      description: 'Balance ledger and reconcile accounts receivable payments.',
      dueDate: DateTime(now.year, now.month, now.day + 3, 9, 0),
      priority: TaskPriority.low,
      isCompleted: false,
      userId: 'demo_user',
      createdAt: now,
    ),
    TaskEntity(
      id: 'task_6',
      title: 'Submit exercise 3.2',
      description: 'Finalize and submit integration test suite report.',
      dueDate: DateTime(now.year, now.month, now.day + 4, 18, 0),
      priority: TaskPriority.high,
      isCompleted: false,
      userId: 'demo_user',
      createdAt: now,
    ),
  ];

  Widget buildPhoneFrame(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: child,
    );
  }

  testWidgets('Generate Onboarding screenshot', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildPhoneFrame(const OnboardingPage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../assets/screenshots/01_onboarding.png'),
    );
  });

  testWidgets('Generate Login screenshot', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: FakeAuthBloc(),
        child: buildPhoneFrame(const LoginPage()),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../assets/screenshots/02_login.png'),
    );
  });

  testWidgets('Generate Dashboard screenshot', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final searchController = TextEditingController();

    await tester.pumpWidget(
      buildPhoneFrame(
        Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              TasksHeader(
                userName: 'Vineet',
                searchController: searchController,
                totalTasks: 6,
                completedTasks: 2,
                pendingTasks: 4,
                onSearchChanged: (_) {},
                onLogout: () {},
              ),
              const SizedBox(height: AppDimensions.p16),
              FilterChipsBar(
                selectedStatus: TaskStatusFilter.all,
                selectedPriority: TaskPriorityFilter.all,
                allCount: 6,
                incompleteCount: 4,
                completedCount: 2,
                onStatusSelected: (_) {},
                onPrioritySelected: (_) {},
              ),
              const SizedBox(height: AppDimensions.p8),
              Expanded(
                child: TaskGroupedList(
                  tasks: sampleTasks,
                  onToggleStatus: (_) {},
                  onEdit: (_) {},
                  onDelete: (_) {},
                ),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: AppColors.primary,
            elevation: 4,
            shape: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 10,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.list_alt_rounded, color: AppColors.primary),
                  onPressed: () {},
                ),
                const SizedBox(width: 48),
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined, color: AppColors.textMuted),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../assets/screenshots/03_dashboard.png'),
    );
  });

  testWidgets('Generate Task Creation Sheet screenshot', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildPhoneFrame(
        Scaffold(
          backgroundColor: Colors.black54,
          body: Align(
            alignment: Alignment.bottomCenter,
            child: TaskFormSheet(
              userId: 'demo_user',
              onSubmit: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../assets/screenshots/04_create_task.png'),
    );
  });

  testWidgets('Generate Calendar View screenshot', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final searchController = TextEditingController();

    await tester.pumpWidget(
      buildPhoneFrame(
        Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              TasksHeader(
                userName: 'Vineet',
                searchController: searchController,
                totalTasks: 6,
                completedTasks: 2,
                pendingTasks: 4,
                onSearchChanged: (_) {},
                onLogout: () {},
              ),
              Expanded(
                child: TaskCalendarView(
                  allTasks: sampleTasks,
                  onToggleStatus: (_) {},
                  onEdit: (_) {},
                  onDelete: (_) {},
                  onAddTaskForDate: (_) {},
                ),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: AppColors.primary,
            elevation: 4,
            shape: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 10,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.list_alt_rounded, color: AppColors.textMuted, size: 26),
                  onPressed: () {},
                ),
                const SizedBox(width: 48),
                IconButton(
                  icon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 26),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../assets/screenshots/05_calendar_view.png'),
    );
  });
}
