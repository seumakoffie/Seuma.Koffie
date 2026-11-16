// lib/widgets/navbar/mega_menu/mega_menu_container.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'menu_dropdown_panel.dart';
import 'about_dropdown_panel.dart';
import 'promo_dropdown_panel.dart';
import 'location_dropdown_panel.dart';

class MegaMenuContainer extends StatelessWidget {
  final String openDropdown; // 'menu' | 'about' | 'promo' | 'location'
  final ValueChanged<String>? onSelectCategory;
  final VoidCallback onExploreMenu;
  final VoidCallback onOrderNow;
  final VoidCallback onScrollToAbout;
  final VoidCallback onScrollToPromo;
  final VoidCallback onScrollToLocation;
  final VoidCallback onClose;

  const MegaMenuContainer({
    super.key,
    required this.openDropdown,
    this.onSelectCategory,
    required this.onExploreMenu,
    required this.onOrderNow,
    required this.onScrollToAbout,
    required this.onScrollToPromo,
    required this.onScrollToLocation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF140602).withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(color: AppColors.gold.withValues(alpha: 0.3), width: 1.2),
          bottom: BorderSide(color: AppColors.caramel.withValues(alpha: 0.25), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 1200,
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
            child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (openDropdown == 'menu')
                MenuDropdownPanel(
                  onSelectCategory: onSelectCategory,
                  onExploreMenu: onExploreMenu,
                  onOrderNow: onOrderNow,
                  onClose: onClose,
                )
              else if (openDropdown == 'about')
                AboutDropdownPanel(
                  onScrollToAbout: onScrollToAbout,
                  onExploreMenu: onExploreMenu,
                  onScrollToLocation: onScrollToLocation,
                  onClose: onClose,
                )
              else if (openDropdown == 'promo')
                PromoDropdownPanel(
                  onScrollToPromo: onScrollToPromo,
                  onClose: onClose,
                )
              else if (openDropdown == 'location')
                LocationDropdownPanel(
                  onScrollToLocation: onScrollToLocation,
                  onClose: onClose,
                ),

              // Top Right Close Button
              Positioned(
                top: -8,
                right: -8,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.close_rounded, color: AppColors.cream, size: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
