// lib/widgets/pro/split_hero_section.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'multi_drink_cup_widget.dart';

class SplitHeroSection extends StatefulWidget {
  final VoidCallback onOrderNow;
  final VoidCallback onExploreMenu;

  const SplitHeroSection({
    super.key,
    required this.onOrderNow,
    required this.onExploreMenu,
  });

  @override
  State<SplitHeroSection> createState() => _SplitHeroSectionState();
}

class _SplitHeroSectionState extends State<SplitHeroSection> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  bool _isIced = false;
  int _drinkIndex = 0;

  DrinkItemData get _currentDrink => kFeaturedDrinks[_drinkIndex];

  void _nextDrink() {
    setState(() {
      _drinkIndex = (_drinkIndex + 1) % kFeaturedDrinks.length;
    });
  }

  void _prevDrink() {
    setState(() {
      _drinkIndex = (_drinkIndex - 1 + kFeaturedDrinks.length) % kFeaturedDrinks.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

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
              child: CustomPaint(painter: _CheckerboardPainter()),
            ),
          ),

          // Content Wrapper
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 20,
                vertical: isDesktop ? 48 : 28,
              ),
              child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
            ),
          ),
        ],
      ),
    );
  }

  // DESKTOP: Asymmetric 2-Column Layout
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Value Prop & CTAs
        Expanded(
          flex: 6,
          child: _buildHeroTextContent(isDesktop: true),
        ),
        const SizedBox(width: 48),
        // Right Column: 3D Stage with Artisanal Sanger Cup
        Expanded(
          flex: 6,
          child: _buildHero3DStage(isDesktop: true),
        ),
      ],
    );
  }

  // MOBILE: Stack Layout
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroTextContent(isDesktop: false),
        const SizedBox(height: 32),
        Center(child: _buildHero3DStage(isDesktop: false)),
      ],
    );
  }

  // Text Content (Headlines, badges, dual CTA)
  Widget _buildHeroTextContent({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trust Pill with localization
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: AppColors.gold, size: 16),
                const SizedBox(width: 7),
                Text(
                  'KINI HADIR DI LHOKSEUMAWE & SEKITARNYA',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: isDesktop ? 11.5 : 10.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Bold Marketplace Headline
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isDesktop ? 46 : 30,
              fontWeight: FontWeight.w900,
              color: AppColors.cream,
              height: 1.12,
              letterSpacing: -0.6,
            ),
            children: [
              const TextSpan(text: 'Kopi Sanger Otentik\n'),
              TextSpan(
                text: 'Seuma.Koffie',
                style: TextStyle(
                  color: AppColors.gold,
                  shadows: [
                    Shadow(
                      color: AppColors.caramel.withValues(alpha: 0.8),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sub-headline localized
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Text(
            'Seni seduhan Kopi Sanger khas Aceh dengan 3 layer otentik — susu kental manis krimer gurih, ekstraksi kopi pekat, dan crema berbusa tebal. Siap diantar kilat 15-20 menit ke mejamu di seluruh penjuru Lhokseumawe.',
            style: TextStyle(
              color: AppColors.cream.withValues(alpha: 0.88),
              fontSize: isDesktop ? 14 : 12.5,
              height: 1.6,
            ),
          ),
        ),

        const SizedBox(height: 26),

        // Dual CTA Buttons
        Wrap(
          spacing: 12,
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
                  horizontal: isDesktop ? 26 : 20,
                  vertical: isDesktop ? 18 : 14,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: Text(
                'Pesan Sekarang (Antar Cepat)',
                style: TextStyle(fontSize: isDesktop ? 13.5 : 12.5, fontWeight: FontWeight.w800),
              ),
            ),
            OutlinedButton.icon(
              onPressed: widget.onExploreMenu,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cream,
                side: BorderSide(color: AppColors.cream.withValues(alpha: 0.4), width: 1.5),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 18,
                  vertical: isDesktop ? 18 : 14,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              icon: const Icon(Icons.menu_book, size: 18),
              label: Text(
                'Lihat Semua Menu',
                style: TextStyle(fontSize: isDesktop ? 13.5 : 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // 4 Value Pillars Banner
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            _buildValueItem(Icons.eco_rounded, '100% Biji Pilihan'),
            _buildValueItem(Icons.local_cafe_rounded, 'Resep Sanger Otentik'),
            _buildValueItem(Icons.bolt_rounded, 'Siap Cepat & Higienis'),
            _buildValueItem(Icons.delivery_dining_rounded, 'Antar Cepat se-Lhokseumawe'),
          ],
        ),
      ],
    );
  }

  Widget _buildValueItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.gold, size: 14),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: AppColors.cream.withValues(alpha: 0.8),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // RIGHT: 3D Stage with Artisanal Multi-Drink Showcase & Interactive Next/Prev Slider
  Widget _buildHero3DStage({required bool isDesktop}) {
    final stageWidth = isDesktop ? 500.0 : 340.0;
    final stageHeight = isDesktop ? 450.0 : 390.0;
    final cupScale = isDesktop ? 1.05 : 0.88;
    final current = _currentDrink;

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = _floatController.value * 10.0;

        return SizedBox(
          width: stageWidth,
          height: stageHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Center Artisanal Animated Cup with Smooth Transition
              Positioned(
                bottom: 50,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) {
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.12, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                        child: child,
                      ),
                    );
                  },
                  child: MultiDrinkCupWidget(
                    key: ValueKey('${current.id}-$_isIced'),
                    drink: current,
                    isIced: _isIced,
                    scale: cupScale,
                  ),
                ),
              ),

              // 2. Next & Prev Floating Navigation Controls (Glassmorphism & Gold Glow)
              // PREV BUTTON (LEFT)
              Positioned(
                left: isDesktop ? 4 : -4,
                top: stageHeight * 0.42,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _prevDrink,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF160A03).withValues(alpha: 0.85),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.55),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.3),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Color(0xFFFFD54F),
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),

              // NEXT BUTTON (RIGHT)
              Positioned(
                right: isDesktop ? 4 : -4,
                top: stageHeight * 0.42,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _nextDrink,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF160A03).withValues(alpha: 0.85),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.55),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.3),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFFFD54F),
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Floating Product Badge 1: Top Right - Rating & Terlaris
              Positioned(
                top: 20 - floatOffset * 0.5,
                right: isDesktop ? -12 : 4,
                child: _buildFloatingBadge(
                  icon: Icons.star_rounded,
                  iconColor: Colors.amber,
                  title: 'Rating 4.9/5',
                  subtitle: '1.2k+ Terjual di Lhokseumawe',
                ),
              ),

              // 4. Floating Product Badge 2: Bottom Left - Signature Price Pill
              Positioned(
                bottom: 80 + floatOffset * 0.5,
                left: isDesktop ? -18 : 4,
                child: _buildFloatingPriceBadge(
                  title: current.name,
                  price: current.price,
                  badge: current.badgeText,
                  onOrder: widget.onOrderNow,
                ),
              ),

              // 5. Floating Badge 3: Top Left - Subtitle / Recipe Highlight
              Positioned(
                top: 45 + floatOffset * 0.4,
                left: isDesktop ? -14 : 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: current.secondaryColor.withValues(alpha: 0.5), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: current.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        current.subtitle,
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 6. Bottom Drink Indicator Pills & Hot/Ice Toggle
              Positioned(
                bottom: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Thermal toggle if applicable
                    if (current.hasIcedOption)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF180A04).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _isIced = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: !_isIced ? AppColors.caramel : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    Text('🔥', style: TextStyle(fontSize: !_isIced ? 12 : 10)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'HOT',
                                      style: TextStyle(
                                        color: !_isIced ? Colors.white : AppColors.cream.withValues(alpha: 0.6),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _isIced = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _isIced ? const Color(0xFF0288D1) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    Text('❄️', style: TextStyle(fontSize: _isIced ? 12 : 10)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ICED',
                                      style: TextStyle(
                                        color: _isIced ? Colors.white : AppColors.cream.withValues(alpha: 0.6),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 5 Drinks Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(kFeaturedDrinks.length, (idx) {
                        final isAct = idx == _drinkIndex;
                        return GestureDetector(
                          onTap: () => setState(() => _drinkIndex = idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isAct ? 26 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isAct ? const Color(0xFFFFD54F) : Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isAct
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFFFD54F).withValues(alpha: 0.6),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingBadge({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F0D03).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.cream.withValues(alpha: 0.75),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingPriceBadge({
    required String title,
    required String price,
    required String badge,
    required VoidCallback onOrder,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF261004).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.caramel.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.caramel,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onOrder,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.caramel,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.caramel.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_shopping_cart_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter for Checkerboard Pattern
class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 14.0;
    final cols = (size.width / squareSize).ceil();
    final rows = (size.height / squareSize).ceil();

    final lightPaint = Paint()..color = const Color(0xFFFBF4E8).withValues(alpha: 0.88);
    final darkPaint = Paint()..color = const Color(0xFF1A0A00).withValues(alpha: 0.92);

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final isEven = (r + c) % 2 == 0;
        final rect = Rect.fromLTWH(c * squareSize, r * squareSize, squareSize, squareSize);
        canvas.drawRect(rect, isEven ? lightPaint : darkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
