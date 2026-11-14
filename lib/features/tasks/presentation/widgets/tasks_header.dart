import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';

class TasksHeader extends StatelessWidget {
  final String userName;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onLogout;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;

  const TasksHeader({
    super.key,
    required this.userName,
    required this.searchController,
    required this.onSearchChanged,
    required this.onLogout,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.pendingTasks = 0,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  double get _progress =>
      totalTasks > 0 ? (completedTasks / totalTasks).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final todayText = DateFormatter.formatHeader(DateTime.now());
    final percentInt = (_progress * 100).toInt();

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.r32),
          bottomRight: Radius.circular(AppDimensions.r32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x334F46E5),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient decorative glowing orb
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.15),
              ),
            ),
          ),

          // Main Header Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.p24,
                AppDimensions.p16,
                AppDimensions.p24,
                AppDimensions.p24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Greeting, Status Pill & Logout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(AppDimensions.rFull),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '⚡',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Gig Shift Active',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppDimensions.p8),
                            Expanded(
                              child: Text(
                                todayText,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.p8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(AppDimensions.r12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                          tooltip: AppStrings.logout,
                          onPressed: onLogout,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.p12),

                  // Title & Personalized Greeting
                  Text(
                    '$_greeting, ${userName.split(' ').first} 👋',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    AppStrings.myTasks,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p16),

                  // Gig Worker Productivity Bar
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.p12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimensions.r16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    color: Color(0xFFFDE047), // Yellow-300
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Daily Progress: $completedTasks of $totalTasks done',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$percentInt%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.p8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.rFull),
                          child: Stack(
                            children: [
                              Container(
                                height: 6,
                                width: double.infinity,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              AnimatedFractionallySizedBox(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                widthFactor: _progress,
                                child: Container(
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF34D399), // Emerald-400
                                        Color(0xFF10B981), // Emerald-500
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p16),

                  // Floating Glass Search Bar (Reference2.png)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.rFull),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: AppStrings.searchTasks,
                        hintStyle: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  searchController.clear();
                                  onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.p20,
                          vertical: AppDimensions.p14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
