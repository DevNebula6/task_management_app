This phase-wise implementation plan is designed to complete the WhatBytes Task Management App before the **November 14, 2026 EOD** deadline.

Notice that the prompt mentions both **local data storage** in the overview and **Firebase/backend storage** in the requirements. Using **Cloud Firestore + Hive** inside a Clean Architecture repository gives us an offline-first experience and checks both evaluation boxes effortlessly.

**Tech Stack & Packages**

* **State Management:** `flutter_bloc`, `equatable`
* **Backend & Auth:** `firebase_core`, `firebase_auth`, `cloud_firestore`


* **Local Caching:** `hive`, `hive_flutter` (for instant offline load & local storage compliance)


* **Dependency Injection & Functional:** `get_it`, `fpdart` (or `dartz` for clean `Either<Failure, Success>` error handling)
* **UI & Responsiveness:** `flutter_screenutil`, `google_fonts`, `intl`, `flutter_slidable` (to match the swipe-to-delete action in `Reference2.png`)



---

**Project Folder Structure (Feature-First Clean Architecture)**

```text
lib/
├── core/
│   ├── constants/       # AppColors, AppStrings, Dimensions
│   ├── error/           # Failures & Custom Exceptions
│   ├── theme/           # AppTheme (Light/Dark, Custom InputDecorations)
│   ├── utils/           # Date formatters, Validators, Responsive extensions
│   └── widgets/         # CustomButton, CustomTextField, LoadingOverlay
├── features/
│   ├── auth/
│   │   ├── data/        # datasources (firebase_auth), models (user_model), repositories
│   │   ├── domain/      # entities (user), repositories, usecases (login, register, logout)
│   │   └── presentation/# bloc (auth_bloc), pages (onboarding, login, signup), widgets
│   └── tasks/
│       ├── data/        # datasources (firestore + hive), models (task_model), repositories
│       ├── domain/      # entities (task), repositories, usecases (crud_task)
│       └── presentation/# bloc (task_bloc), pages (home_page, task_sheet), widgets (task_tile, filter_bar)
├── injection_container.dart
└── main.dart

```

---

**Phase 1: Foundation, Core & Firebase Setup (Est. 1 Hour)**

* **Goal:** Configure project dependencies, Firebase, and the design system matching the reference screens (`#6C63FF` primary indigo/purple, soft grey backgrounds, orange/amber/indigo priority badges).


* **Deliverables:**
1. Initialize Firebase (`flutterfire configure`) with Email/Password Auth and Cloud Firestore enabled.


2. Set up `core/theme/app_theme.dart` with custom `InputDecorationTheme` (rounded pill/card inputs), typography (`Poppins` or `Inter`), and responsive sizing setup.
3. Build `core/error/failures.dart` with human-readable Firebase Auth error mappers (`invalid-credential`, `email-already-in-use`, `weak-password`).


4. Initialize Hive boxes and `get_it` service locator in `injection_container.dart`.



**Phase 2: Authentication Feature — Clean Arch + BLoC (Est. 2 Hours)**

* **Goal:** Build the Onboarding and Auth flows matching `Reference1.png`.


* **Domain & Data:**
1. Create `UserEntity` and `UserModel`.
2. Implement `AuthRemoteDataSource` using `FirebaseAuth` (`signInWithEmailAndPassword`, `createUserWithEmailAndPassword`, `signOut`, `authStateChanges`).




* **BLoC (`AuthBloc`):**
1. Events: `AuthCheckRequested`, `AuthLoginSubmitted`, `AuthRegisterSubmitted`, `AuthLogoutRequested`.
2. States: `AuthInitial`, `AuthLoading`, `Authenticated(UserEntity)`, `Unauthenticated`, `AuthError(String message)`.


* UI Screens (`Reference1.png`):


1. **Onboarding Page:** Centered checkmark icon card with decorative dots, *"Get things done."* header, subtitle, and floating bottom-right circular arrow button.


2. **Login & Signup Pages:** Clean form validation, loading state inside the primary rounded pill button, and custom `SnackBar` toasts for invalid credentials.





**Phase 3: Task Management Core — Firestore + Hive Sync (Est. 2.5 Hours)**

* **Goal:** Build CRUD operations with real-time or cached syncing and clean domain entities.


* **Domain & Data:**
1. Define `TaskPriority` enum (`low`, `medium`, `high`).


2. Create `TaskEntity` & `TaskModel`: `id`, `userId`, `title`, `description`, `dueDate`, `priority`, `isCompleted`, `createdAt`.


3. Implement `TaskRemoteDataSource` (Firestore `users/{uid}/tasks` collection) and `TaskLocalDataSource` (Hive cache so tasks load instantaneously and work offline).




* **BLoC (`TaskBloc`):**
1. Maintain both `allTasks` and `filteredTasks` inside `TaskLoaded` state so filtering and sorting happen instantaneously in-memory without redundant Firestore reads.
2. Auto-sort tasks by `dueDate` ascending (`a.dueDate.compareTo(b.dueDate)`) on every state emission.





**Phase 4: Task Dashboard, Grouping & Filtering UI (Est. 2.5 Hours)**

* **Goal:** Recreate the `Reference2.png` dashboard with date grouping, priority pills, and filter chips.


* **UI Components:**
1. **Custom Curved/Colored AppBar:** Indigo header with search bar (`Search tasks...`), current date label (*"Today, 13 Nov"*), and *"My tasks"* title.


2. **Filter Bar:** Horizontal filter chips right below the header for **Status** (*All, Incomplete, Completed*) and **Priority** (*All, High, Medium, Low*).


3. **Date-Grouped ListView:** Group the sorted tasks dynamically into **"Today"**, **"Tomorrow"**, **"This week"**, and **"Later"** sections just like `Reference2.png`.


4. **Task Tile & Slidable:** Custom circular checkbox (toggles `isCompleted`), task title (with strikethrough when completed), due date subtitle, color-coded priority pill, and `Slidable` swipe-left action revealing the circular red delete button and edit action.


5. **Add/Edit Task BottomSheet:** Smooth modal sheet with title, description, date picker, and interactive priority selector chips.


6. **Bottom App Bar + Center Docked FAB:** Floating purple `+` button docked between the Task List and Calendar/Filter tabs.





**Phase 5: Polish, Edge Cases & Submission Prep (Est. 1 Hour)**

* **Goal:** Make the app stand out during evaluation.
* **Deliverables:**
1. **Empty & Loading States:** Subtle shimmer or clean illustration when no tasks match the active filter.
2. **Micro-interactions:** Haptic feedback on task completion toggle and smooth `AnimatedSwitcher` transitions between filter states.
3. **README & Demo:** Write a concise `README.md` documenting the Clean Architecture layers, BLoC state flow, offline Hive caching, and build instructions.


