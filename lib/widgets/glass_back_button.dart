import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GlassBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const GlassBackButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.black,
          size: 22,
        ),
      ),
    );
  }
}
