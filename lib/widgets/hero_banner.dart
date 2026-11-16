// lib/widgets/hero_banner.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HeroBanner extends StatefulWidget {
  final VoidCallback onExploreMenu;
  final VoidCallback onOrderNow;

  const HeroBanner({
    super.key,
    required this.onExploreMenu,
    required this.onOrderNow,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
      ),
      child: Stack(
        children: [
          // Checkerboard header accent reminiscent of the Seuma.Koffie menu header
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 14,
              child: CustomPaint(
                painter: _CheckerboardPainter(),
              ),
            ),
          ),

          // Animated Floating Coffee Beans in background
          Positioned(
            right: isDesktop ? 60 : 16,
            top: isDesktop ? 40 : 60,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -14 * _animController.value),
                  child: Transform.rotate(
                    angle: (_animController.value - 0.5) * 0.12,
                    child: Container(
                      width: isDesktop ? 180 : 110,
                      height: isDesktop ? 180 : 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.caramel.withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '☕',
                          style: TextStyle(
                            fontSize: isDesktop ? 76 : 52,
                            shadows: [
                              Shadow(
                                color: AppColors.caramel.withValues(alpha: 0.6),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Content Container
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 20,
                vertical: isDesktop ? 64 : 44,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),

                  // Brand Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.caramel.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.caramel.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.gold, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'KINI HADIR DI LHOKSEUMAWE & SEKITARNYA',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: isDesktop ? 11 : 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Headline
                  Text.rich(
                    TextSpan(
                      text: 'Kopi Terbaik\nDari ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 54 : 32,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Seuma.',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text: 'Koffie',
                          style: TextStyle(
                            color: AppColors.caramel,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Sub-headline
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: Text(
                      'Nikmati keaslian racikan Kopi Sanger otentik, Kopi Susu Aren, hingga Mocktail tropis segar yang diracik presisi untuk penikmat kopi di Lhokseumawe dan sekitarnya.',
                      style: TextStyle(
                        color: AppColors.cream.withValues(alpha: 0.85),
                        fontSize: isDesktop ? 15 : 13,
                        height: 1.55,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Action Buttons
                  Wrap(
                    spacing: 14,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: widget.onOrderNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.caramel,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: AppColors.caramel.withValues(alpha: 0.6),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 28 : 22,
                            vertical: isDesktop ? 18 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                        label: Text(
                          'Pesan Sekarang',
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: widget.onExploreMenu,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.cream,
                          side: BorderSide(color: AppColors.cream.withValues(alpha: 0.4), width: 1.5),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 26 : 20,
                            vertical: isDesktop ? 18 : 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(Icons.menu_book, size: 18),
                        label: Text(
                          'Lihat Semua Menu',
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Features Strip
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Wrap(
                      spacing: isDesktop ? 28 : 16,
                      runSpacing: 8,
                      children: [
                        _buildFeatureTag('🌱 100% Biji Pilihan'),
                        _buildFeatureTag('🥛 Resep Sanger Otentik'),
                        _buildFeatureTag('⚡ Siap Cepat & Higienis'),
                        _buildFeatureTag('🛵 Antar Cepat se-Lhokseumawe'),
                      ],
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

  Widget _buildFeatureTag(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: AppColors.cream,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paintWhite = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    const boxSize = 14.0;
    final count = (size.width / boxSize).ceil();
    for (int i = 0; i < count; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(i * boxSize, 0, boxSize, size.height),
          paintWhite,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
