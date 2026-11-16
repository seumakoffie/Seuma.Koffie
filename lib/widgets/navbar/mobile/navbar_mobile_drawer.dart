// lib/widgets/navbar/mobile/navbar_mobile_drawer.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../components/navbar_logo.dart';

class NavbarMobileDrawer {
  static void show(
    BuildContext context, {
    required VoidCallback onExploreMenu,
    required VoidCallback onScrollToAbout,
    required VoidCallback onScrollToPromo,
    required VoidCallback onScrollToLocation,
    required VoidCallback onOrderNow,
    required VoidCallback onShowAuth,
    VoidCallback? onScrollToTop,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, anim, _) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, _, _) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              constraints: const BoxConstraints(maxWidth: 320, minWidth: 260),
              height: double.infinity,
              color: const Color(0xFF130602),
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    NavbarLogo(
                      onScrollToTop: () {
                        Navigator.pop(context);
                        onScrollToTop?.call();
                      },
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.restaurant_menu_rounded, color: AppColors.gold, size: 20),
                      title: const Text('Menu Lengkap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.caramel),
                      onTap: () {
                        Navigator.pop(context);
                        onExploreMenu();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
                      title: const Text('Tentang Kami', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.caramel),
                      onTap: () {
                        Navigator.pop(context);
                        onScrollToAbout();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.local_offer_rounded, color: AppColors.gold, size: 20),
                      title: const Text('Promo Aktif', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.caramel),
                      onTap: () {
                        Navigator.pop(context);
                        onScrollToPromo();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on_rounded, color: AppColors.gold, size: 20),
                      title: const Text('Lokasi & Pengantaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.caramel),
                      onTap: () {
                        Navigator.pop(context);
                        onScrollToLocation();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_rounded, color: AppColors.gold, size: 20),
                      title: const Text('Masuk / Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.caramel),
                      onTap: () {
                        Navigator.pop(context);
                        onShowAuth();
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onOrderNow();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.caramel,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.bolt_rounded, size: 18),
                      label: const Text('Pesan Sekarang', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
