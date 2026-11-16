// lib/widgets/navbar/components/navbar_order_button.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NavbarOrderButton extends StatelessWidget {
  final VoidCallback onOrderNow;

  const NavbarOrderButton({super.key, required this.onOrderNow});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onOrderNow,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            gradient: AppColors.caramelGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.caramel.withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'Pesan Sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
