// lib/widgets/navbar/mobile/navbar_mobile_drawer.dart
// Modern Luxury Mobile & Tablet Navigation Drawer for Seuma.Koffie v6.0
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../state/auth_state.dart';
import '../components/navbar_logo.dart';
import '../../admin/admin_dashboard_dialog.dart';

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
      barrierLabel: 'NavMobileDrawer',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, anim, _) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, _, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth >= 600;
        final drawerWidth = isTablet ? 380.0 : (screenWidth * 0.85).clamp(280.0, 340.0);

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: drawerWidth,
              height: double.infinity,
              child: Material(
                // Crucial: Must be wrapped in Material widget to avoid grey screen error
                color: const Color(0xFF140602),
                elevation: 24,
                child: SafeArea(
                  child: Column(
                    children: [
                      // ── TOP HEADER (Logo + Close Button) ────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NavbarLogo(
                              onScrollToTop: () {
                                Navigator.pop(context);
                                onScrollToTop?.call();
                              },
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: AppColors.cream,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: Colors.white12, height: 1),

                      // ── SCROLLABLE MENU ITEMS ───────────────────────────
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            // ── User Member Card ─────────────────────────
                            ListenableBuilder(
                              listenable: AuthManager.instance,
                              builder: (context, _) {
                                final user = AuthManager.instance.currentUser;
                                final isLoggedIn = user != null;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF220E05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.gold.withValues(alpha: 0.35),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFD48B38), Color(0xFFE5A65E)],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.caramel.withValues(alpha: 0.4),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            isLoggedIn ? user.name[0].toUpperCase() : '☕',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isLoggedIn ? user.name : 'Sahabat Seuma',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              isLoggedIn
                                                  ? '🌟 ${user.memberTier} • ${user.points} Poin'
                                                  : 'Masuk / Daftar untuk promo',
                                              style: const TextStyle(
                                                color: Color(0xFFFFD54F),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          onShowAuth();
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: AppColors.caramel.withValues(alpha: 0.25),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
                                          ),
                                        ),
                                        child: Text(
                                          isLoggedIn ? 'Akun' : 'Masuk',
                                          style: const TextStyle(
                                            color: Color(0xFFFFD54F),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            // ── Navigation List Items ────────────────────
                            _buildDrawerTile(
                              icon: Icons.coffee_rounded,
                              label: 'Daftar Menu Favorit',
                              badge: '50+ Pilihan',
                              badgeColor: const Color(0xFFFFB300),
                              onTap: () {
                                Navigator.pop(context);
                                onExploreMenu();
                              },
                            ),
                            _buildDrawerTile(
                              icon: Icons.bolt_rounded,
                              label: 'Promo Kilat & Diskon',
                              badge: 'Hemat s/d 30%',
                              badgeColor: const Color(0xFFFF5722),
                              onTap: () {
                                Navigator.pop(context);
                                onScrollToPromo();
                              },
                            ),
                            _buildDrawerTile(
                              icon: Icons.auto_stories_rounded,
                              label: 'Filosofi Sanger & Cerita',
                              onTap: () {
                                Navigator.pop(context);
                                onScrollToAbout();
                              },
                            ),
                            _buildDrawerTile(
                              icon: Icons.location_on_rounded,
                              label: 'Lokasi & Pengantaran',
                              badge: '15-20 Mnt',
                              badgeColor: const Color(0xFF4CAF50),
                              onTap: () {
                                Navigator.pop(context);
                                onScrollToLocation();
                              },
                            ),
                            _buildDrawerTile(
                              icon: Icons.shield_rounded,
                              label: 'Keamanan Data E2EE',
                              badge: 'Blockchain',
                              badgeColor: const Color(0xFF00BCD4),
                              onTap: () {
                                Navigator.pop(context);
                                onShowAuth();
                              },
                            ),
                            _buildDrawerTile(
                              icon: Icons.admin_panel_settings_rounded,
                              label: 'Portal Admin & Penjaga Shift',
                              badge: 'Pesanan & Shift',
                              badgeColor: const Color(0xFFD4AF37),
                              onTap: () {
                                Navigator.pop(context);
                                AdminDashboardDialog.show(context);
                              },
                            ),

                            const SizedBox(height: 14),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 10),

                            // ── Trust Badges Strip ───────────────────────
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.verified_rounded, color: AppColors.gold, size: 14),
                                      SizedBox(width: 6),
                                      Text(
                                        'JAMINAN AUTENTIK SEUMA',
                                        style: TextStyle(
                                          color: AppColors.gold,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '100% Biji Gayo Pilihan • Halal Indonesia • Siap Antar Banda Sakti, Muara Dua, Muara Satu & Blang Mangat.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── STICKY BOTTOM ACTION (Order Now CTA) ────────────
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF100401),
                          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFD48B38), Color(0xFFE5A65E)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.caramel.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onOrderNow();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                                  label: const Text(
                                    'Pesan Kopi Sekarang',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Buka Setiap Hari • Siap Antar 15-20 Mnt',
                              style: TextStyle(color: Colors.white38, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildDrawerTile({
    required IconData icon,
    required String label,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                  ),
                  child: Icon(icon, color: AppColors.gold, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? AppColors.caramel).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: (badgeColor ?? AppColors.caramel).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: badgeColor ?? AppColors.gold,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Colors.white30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
