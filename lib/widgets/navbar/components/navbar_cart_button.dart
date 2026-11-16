// lib/widgets/navbar/components/navbar_cart_button.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../state/cart_state.dart';

class NavbarCartButton extends StatelessWidget {
  final VoidCallback onShowCart;

  const NavbarCartButton({super.key, required this.onShowCart});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartManager.instance,
      builder: (context, _) {
        final count = CartManager.instance.totalItems;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onShowCart,
            child: Badge(
              isLabelVisible: count > 0,
              backgroundColor: AppColors.caramel,
              label: Text(
                '$count',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.white),
              ),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.gold,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
