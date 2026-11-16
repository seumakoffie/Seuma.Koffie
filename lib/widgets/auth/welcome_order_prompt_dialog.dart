// lib/widgets/auth/welcome_order_prompt_dialog.dart
// Interactive Modern Welcome Gate Dialog for First-Time Orders
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../auth_dialog.dart';

class WelcomeOrderPromptDialog extends StatefulWidget {
  const WelcomeOrderPromptDialog({super.key});

  /// Displays the interactive welcome prompt dialog
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => const Center(
        child: WelcomeOrderPromptDialog(),
      ),
    );
  }

  @override
  State<WelcomeOrderPromptDialog> createState() => _WelcomeOrderPromptDialogState();
}

class _WelcomeOrderPromptDialogState extends State<WelcomeOrderPromptDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openAuth({required bool isRegister}) {
    Navigator.of(context).pop(); // Dismiss welcome modal
    AuthDialog.show(
      context,
      isRegister: isRegister,
      reasonMessage: isRegister
          ? 'Buat akun untuk nikmati kemudahan order dan pengantaran 15-20 menit!'
          : 'Silakan masuk ke akun Seuma Anda untuk melanjutkan pesanan.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 520,
                maxHeight: size.height * 0.9,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1B0B04), // Dark espresso roast
                      Color(0xFF2B1306), // Warm rich dark coffee
                      Color(0xFF150802),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.22),
                      blurRadius: 36,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.7),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // Background ambient glowing circles
                      Positioned(
                        top: -60,
                        right: -60,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gold.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: -40,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.caramel.withValues(alpha: 0.1),
                          ),
                        ),
                      ),

                      // Content Scrollable
                      SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20 : 32,
                          vertical: isMobile ? 24 : 32,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ── Top Header Row with Badge & Exit Button ────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.gold.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('☕', style: TextStyle(fontSize: 12)),
                                      SizedBox(width: 6),
                                      Text(
                                        'SEUMA.KOFFIE • ACEH',
                                        style: TextStyle(
                                          color: Color(0xFFFFD54F),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Modern Exit Button
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.08),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── Animated Mascot / Steaming Cup Icon ────────────
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: 78,
                                height: 78,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    colors: [
                                      Color(0xFFD4AF37), // Golden center
                                      Color(0xFF8B4513), // Saddle brown
                                      Color(0xFF1E0E05),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold.withValues(alpha: 0.45),
                                      blurRadius: 22,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Text('☕', style: TextStyle(fontSize: 40)),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // ── Headline ─────────────────────────────────────
                            const Text(
                              'Ingin Melakukan Pemesanan?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                                height: 1.25,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ── Subtitle Explanation ──────────────────────────
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Color(0xFFFFF9F2),
                                  fontSize: 13,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Untuk menjamin keamanan transaksi & pengantaran kilat ',
                                  ),
                                  TextSpan(
                                    text: '15–20 Menit di Kota Lhokseumawe',
                                    style: TextStyle(
                                      color: Color(0xFFFFD54F),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ', silakan ',
                                  ),
                                  TextSpan(
                                    text: 'Daftar Akun Baru',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' atau ',
                                  ),
                                  TextSpan(
                                    text: 'Masuk (Login)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' jika sudah memiliki akun Seuma.Koffie.',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── 3 Value Cards (Why Register?) ─────────────────
                            _buildFeaturePill(
                              icon: Icons.flash_on_rounded,
                              iconColor: const Color(0xFFFFB300),
                              title: 'Siap Antar Kilat 15–20 Menit',
                              desc: 'Wilayah Banda Sakti, Muara Dua, Muara Satu & Blang Mangat',
                            ),
                            const SizedBox(height: 8),
                            _buildFeaturePill(
                              icon: Icons.shield_rounded,
                              iconColor: const Color(0xFF66BB6A),
                              title: 'Proteksi Data Blockchain & E2EE',
                              desc: 'Enkripsi AES-256 melindungi privasi alamat & transaksi Anda',
                            ),
                            const SizedBox(height: 8),
                            _buildFeaturePill(
                              icon: Icons.card_giftcard_rounded,
                              iconColor: const Color(0xFFFFA726),
                              title: 'Bonus Poin & Promo Khusus Member',
                              desc: 'Dapatkan 250 poin selamat datang dan voucher seduhan gratis',
                            ),

                            const SizedBox(height: 24),

                            // ── Action Buttons ────────────────────────────────
                            // 1. Primary CTA: Register
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD48B38), // Rich caramel
                                      Color(0xFFE5A65E), // Warm gold
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.caramel.withValues(alpha: 0.45),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () => _openAuth(isRegister: true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                                  label: const Text(
                                    'Daftar Akun Baru Sekarang',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 2. Secondary CTA: Login
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _openAuth(isRegister: false),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(
                                    color: AppColors.gold.withValues(alpha: 0.7),
                                    width: 1.4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: const Color(0xFF281307),
                                ),
                                icon: const Icon(Icons.login_rounded, color: Color(0xFFFFD54F), size: 19),
                                label: const Text(
                                  'Sudah Punya Akun? Masuk (Login)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 3. Subtle Exit / Browse Menu Button
                            TextButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.cream.withValues(alpha: 0.8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              icon: const Icon(Icons.menu_book_rounded, size: 16),
                              label: const Text(
                                'Lanjut Jelajahi Menu Dulu (Tutup)',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
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
        ),
      ),
    );
  }

  Widget _buildFeaturePill({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF130702).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFFFD54F),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Color(0xFFFFF9F2),
                    fontSize: 10.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
