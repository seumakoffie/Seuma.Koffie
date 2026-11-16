// lib/widgets/navbar/components/navbar_logo.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NavbarLogo extends StatelessWidget {
  final VoidCallback? onScrollToTop;

  const NavbarLogo({super.key, this.onScrollToTop});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onScrollToTop,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppColors.caramelGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.caramel.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.coffee_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19, letterSpacing: -0.3),
                children: [
                  TextSpan(text: 'Seuma', style: TextStyle(color: Colors.white)),
                  TextSpan(text: '.', style: TextStyle(color: AppColors.gold)),
                  TextSpan(text: 'Koffie', style: TextStyle(color: AppColors.gold)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
              ),
              child: const Text(
                'ACEH',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
