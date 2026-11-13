import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialItem(
          icon: Icons.g_mobiledata_rounded,
          iconSize: 32,
          color: const Color(0xFFEA4335),
        ),
        const SizedBox(width: AppDimensions.p20),
        _buildSocialItem(
          icon: Icons.apple_rounded,
          iconSize: 26,
          color: AppColors.textPrimary,
        ),
        const SizedBox(width: AppDimensions.p20),
        _buildSocialItem(
          icon: Icons.facebook_rounded,
          iconSize: 26,
          color: const Color(0xFF1877F2),
        ),
      ],
    );
  }

  Widget _buildSocialItem({
    required IconData icon,
    required double iconSize,
    required Color color,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}
