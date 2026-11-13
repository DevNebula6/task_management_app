# Task Management App for Gig Workers 🚀

A production-grade, visually stunning Task Management mobile application tailored for gig workers to organize, prioritize, and track their daily tasks effortlessly.

Built for the **WhatBytes Flutter Developer Intern Assignment**.

---

## 📱 Features & Highlights

- **User Authentication:**
  - Secure registration and login powered by **Firebase Authentication** (Email & Password).
  - Robust credential validation with custom, human-readable error handling.
  - Automatic session caching via **Hive** for instant app launch.
- **Task Management (CRUD):**
  - Create, view, update, and delete tasks.
  - Full task attributes: `Title`, `Description`, `Due Date & Time`, and `Priority` (`Low`, `Medium`, `High`).
  - Toggle task completion status with custom animated circular checkboxes and strikethrough styling.
- **Task Sorting & Categorization:**
  - Dynamic grouping into **"Today"**, **"Tomorrow"**, **"This week"**, **"Later"**, and **"Overdue"** sections matching the reference design.
  - Auto-sorted by due date (`earliest to latest`).
- **Reactive In-Memory Filtering & Search:**
  - Horizontal filter chips for **Status** (*All, Incomplete, Completed*).
  - Horizontal filter chips for **Priority** (*All, High, Medium, Low*).
  - Live search bar filtering by title and description.
- **Offline-First Synchronous Architecture:**
  - Dual-tier storage: **Cloud Firestore** for remote sync and **Hive** for instantaneous local caching.
  - Optimistic UI updates with zero lag.
- **UI & Micro-interactions:**
  - Styled after `Reference1.png` and `Reference2.png`.
  - Modern indigo primary palette (`#5B50E5`), curved header with date banner, docked central FAB (`+`), and swipe-to-delete with `flutter_slidable`.

---

## 🏛️ Architecture & Project Structure

The project follows a **Feature-First Clean Architecture** with **BLoC** for deterministic, unidirectional state management:

```text
lib/
├── core/
│   ├── constants/       # AppColors, AppStrings, AppDimensions
│   ├── error/           # Failures & Custom Exceptions
│   ├── theme/           # AppTheme (Light theme, typography, input decorations)
│   ├── utils/           # Date formatters, Validators
│   └── widgets/         # CustomButton, CustomTextField, AppSnackBar
├── features/
│   ├── auth/
│   │   ├── data/        # UserModel, AuthRemoteDataSource, AuthLocalDataSource, AuthRepositoryImpl
│   │   ├── domain/      # UserEntity, AuthRepository, UseCases (Login, Register, Logout, etc.)
│   │   └── presentation/# AuthBloc, OnboardingPage, LoginPage, SignupPage
│   └── tasks/
│       ├── data/        # TaskModel, TaskRemoteDataSource, TaskLocalDataSource, TaskRepositoryImpl
│       ├── domain/      # TaskEntity, TaskRepository, UseCases (Create, Update, Delete, etc.)
│       └── presentation/# TaskBloc, HomePage, TaskGroupedList, TaskTile, FilterChips, TaskFormSheet
├── firebase_options.dart # Generated Firebase configuration
├── injection_container.dart # GetIt dependency injection setup
└── main.dart            # App entrypoint with MultiBlocProvider
```

---

## 🛠️ Tech Stack & Packages

- **State Management:** `flutter_bloc: ^9.1.1`, `equatable: ^3.0.0`
- **Backend & Auth:** `firebase_core`, `firebase_auth`, `cloud_firestore`
- **Local Storage:** `hive`, `hive_flutter`
- **Dependency Injection & Error Handling:** `get_it`, `dartz`
- **UI & Animations:** `google_fonts` (Poppins), `intl`, `flutter_slidable`, `uuid`

---

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK `^3.13.4` (tested on Flutter `3.47.5`)
- Android Studio / Xcode / Android Emulator or Physical Device

### 2. Installation
```bash
# Clone the repository
git clone <repo-url>
cd task_management_app

# Fetch dependencies
flutter pub get
```

### 3. Run the App
```bash
# Run on connected device/emulator
flutter run
```

### 4. Run Tests & Static Analysis
```bash
# Run static code analysis (0 warnings/errors)
flutter analyze

# Run unit and widget test suite
flutter test
```
