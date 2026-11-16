// lib/widgets/pro/multi_drink_cup_widget.dart
// Interactive Multi-Drink Visual Widget with Fluid Layering & Particle Animations
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum DrinkVariant {
  sanger,
  matcha,
  taro,
  redVelvet,
  mangoSquash,
}

class DrinkItemData {
  final String id;
  final String name;
  final String subtitle;
  final String price;
  final DrinkVariant variant;
  final String badgeText;
  final String iconEmoji;
  final Color primaryColor;
  final Color secondaryColor;
  final Color creamColor;
  final bool hasIcedOption;

  const DrinkItemData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.variant,
    required this.badgeText,
    required this.iconEmoji,
    required this.primaryColor,
    required this.secondaryColor,
    required this.creamColor,
    this.hasIcedOption = true,
  });
}

/// The 5 Featured Animated Drinks Showcase
const List<DrinkItemData> kFeaturedDrinks = [
  DrinkItemData(
    id: 'sanger-hot',
    name: 'Hot Sanger Espresso',
    subtitle: 'Signature 3-Layer Kopi Aceh Otentik',
    price: 'Rp 10.000',
    variant: DrinkVariant.sanger,
    badgeText: 'BESTSELLER #1',
    iconEmoji: '☕',
    primaryColor: Color(0xFF281105), // Deep Espresso
    secondaryColor: Color(0xFF5A2A0C),
    creamColor: Color(0xFFFFF3E0), // Condensed milk
    hasIcedOption: true,
  ),
  DrinkItemData(
    id: 'matcha-latte',
    name: 'Matcha Uji Latte',
    subtitle: 'Green Tea Giok Jepang & Creamy Milk',
    price: 'Rp 18.000',
    variant: DrinkVariant.matcha,
    badgeText: 'FAVORIT MEMBER ✨',
    iconEmoji: '🍵',
    primaryColor: Color(0xFF2D5A27), // Jade Matcha Green
    secondaryColor: Color(0xFF4C8A3E),
    creamColor: Color(0xFFF1F8E9),
    hasIcedOption: true,
  ),
  DrinkItemData(
    id: 'taro-velvet',
    name: 'Taro Velvet Bliss',
    subtitle: 'Ubi Ungu Gurih & Vanilla Cream Swirl',
    price: 'Rp 16.000',
    variant: DrinkVariant.taro,
    badgeText: 'MENU BARU 🍠',
    iconEmoji: '🍠',
    primaryColor: Color(0xFF5E35B1), // Deep Royal Taro Purple
    secondaryColor: Color(0xFF8E6DC8),
    creamColor: Color(0xFFF3E5F5),
    hasIcedOption: true,
  ),
  DrinkItemData(
    id: 'red-velvet',
    name: 'Red Velvet Macchiato',
    subtitle: 'Ruby Cocoa Infusion & Thick Foam',
    price: 'Rp 17.000',
    variant: DrinkVariant.redVelvet,
    badgeText: 'PREMIUM COCOA 🍰',
    iconEmoji: '🍰',
    primaryColor: Color(0xFF881B24), // Ruby Red Cocoa
    secondaryColor: Color(0xFFB72B35),
    creamColor: Color(0xFFFFF0F1),
    hasIcedOption: true,
  ),
  DrinkItemData(
    id: 'mango-squash',
    name: 'Mango Tropical Squash',
    subtitle: 'Soda Dingin Bersoda & Sari Mangga Asli',
    price: 'Rp 14.000',
    variant: DrinkVariant.mangoSquash,
    badgeText: 'SEGAR TROPIS 🥭',
    iconEmoji: '🥭',
    primaryColor: Color(0xFFFF8F00), // Rich Mango Gold
    secondaryColor: Color(0xFFFFB300),
    creamColor: Color(0xFFFFFDE7),
    hasIcedOption: false, // Always iced/fresh
  ),
];

class MultiDrinkCupWidget extends StatefulWidget {
  final DrinkItemData drink;
  final bool isIced;
  final double scale;

  const MultiDrinkCupWidget({
    super.key,
    required this.drink,
    this.isIced = false,
    this.scale = 1.0,
  });

  @override
  State<MultiDrinkCupWidget> createState() => _MultiDrinkCupWidgetState();
}

class _MultiDrinkCupWidgetState extends State<MultiDrinkCupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final animValue = _animController.value;

        return Transform.scale(
          scale: widget.scale,
          child: SizedBox(
            width: 260,
            height: 320,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Ambient Glow Halo Behind Cup
                Positioned(
                  bottom: 40,
                  child: Container(
                    width: 220,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.drink.primaryColor.withValues(alpha: 0.55),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.25),
                          blurRadius: 35,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Animated Steam Waves (for Hot) or Floating Frost/Ice (for Iced)
                Positioned(
                  top: 15,
                  child: CustomPaint(
                    size: const Size(180, 80),
                    painter: _SteamOrParticlesPainter(
                      progress: animValue,
                      isIced: widget.isIced,
                      variant: widget.drink.variant,
                      accentColor: widget.drink.secondaryColor,
                    ),
                  ),
                ),

                // 3. Realistic Artisanal Glass Cup
                Positioned(
                  bottom: 25,
                  child: Container(
                    width: 175,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(38),
                        bottomRight: Radius.circular(38),
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.45),
                        width: 2.2,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                      child: Stack(
                        children: [
                          // Drink Liquid Layer Painter
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _DrinkLiquidPainter(
                                drink: widget.drink,
                                isIced: widget.isIced,
                                progress: animValue,
                              ),
                            ),
                          ),

                          // Glass Rim Highlight (Left & Right)
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: 14,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.4),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Brand Stamp inside the glass
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                widget.drink.iconEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Glass Base Saucer Plate
                Positioned(
                  bottom: 14,
                  child: Container(
                    width: 195,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// CustomPainter for rendering distinct 3-layer artisanal drink gradients & wave textures
class _DrinkLiquidPainter extends CustomPainter {
  final DrinkItemData drink;
  final bool isIced;
  final double progress;

  _DrinkLiquidPainter({
    required this.drink,
    required this.isIced,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final waveOffset = math.sin(progress * 2 * math.pi) * 3;

    // ── LAYER 1: BASE LAYER (Condensed Milk / Thick Sweet Base) ──────────
    final baseHeight = size.height * 0.32;
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          drink.creamColor,
          drink.creamColor.withValues(alpha: 0.92),
        ],
      ).createShader(Rect.fromLTWH(0, size.height - baseHeight, size.width, baseHeight));

    canvas.drawRect(
      Rect.fromLTWH(0, size.height - baseHeight, size.width, baseHeight),
      basePaint,
    );

    // ── LAYER 2: MIDDLE INFUSION LAYER (Espresso / Matcha / Taro / Velvet) ─
    final midHeight = size.height * 0.44;
    final midPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          drink.primaryColor,
          drink.secondaryColor,
        ],
      ).createShader(Rect.fromLTWH(0, size.height - baseHeight - midHeight, size.width, midHeight));

    final midPath = Path()
      ..moveTo(0, size.height - baseHeight)
      ..lineTo(0, size.height - baseHeight - midHeight + waveOffset)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height - baseHeight - midHeight - waveOffset,
        size.width,
        size.height - baseHeight - midHeight + waveOffset,
      )
      ..lineTo(size.width, size.height - baseHeight)
      ..close();

    canvas.drawPath(midPath, midPaint);

    // ── LAYER 3: TOP CREMA / FOAM / FIZZ LAYER ───────────────────────────
    final topHeight = size.height * 0.24;
    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          drink.secondaryColor.withValues(alpha: 0.8),
          drink.creamColor.withValues(alpha: 0.95),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, topHeight + 20));

    final topPath = Path()
      ..moveTo(0, size.height - baseHeight - midHeight + waveOffset)
      ..lineTo(0, 15 + waveOffset * 0.5)
      ..quadraticBezierTo(
        size.width * 0.5,
        15 - waveOffset * 0.5,
        size.width,
        15 + waveOffset * 0.5,
      )
      ..lineTo(size.width, size.height - baseHeight - midHeight + waveOffset)
      ..close();

    canvas.drawPath(topPath, topPaint);

    // If Iced, draw translucent ice cubes floating
    if (isIced) {
      final icePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.42)
        ..style = PaintingStyle.fill;

      final iceBorder = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      final cubes = [
        RRect.fromRectAndRadius(
          Rect.fromLTWH(30, 45 + waveOffset, 36, 36),
          const Radius.circular(8),
        ),
        RRect.fromRectAndRadius(
          Rect.fromLTWH(95, 35 - waveOffset, 42, 42),
          const Radius.circular(8),
        ),
        RRect.fromRectAndRadius(
          Rect.fromLTWH(55, 95 + waveOffset * 0.8, 38, 38),
          const Radius.circular(8),
        ),
      ];

      for (final cube in cubes) {
        canvas.drawRRect(cube, icePaint);
        canvas.drawRRect(cube, iceBorder);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrinkLiquidPainter oldDelegate) => true;
}

/// Dynamic particle animator: Steam waves for hot beverages or sparkling bubbles for iced
class _SteamOrParticlesPainter extends CustomPainter {
  final double progress;
  final bool isIced;
  final DrinkVariant variant;
  final Color accentColor;

  _SteamOrParticlesPainter({
    required this.progress,
    required this.isIced,
    required this.variant,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isIced) {
      // Effervescent sparkle bubbles rising
      final bubblePaint = Paint()..style = PaintingStyle.fill;
      for (int i = 0; i < 7; i++) {
        final t = (progress + (i * 0.14)) % 1.0;
        final y = size.height * (1.0 - t);
        final x = size.width * 0.2 + (i * 18.0) + math.sin(t * math.pi * 3) * 8;
        final radius = 2.5 + (i % 3) * 1.5;
        final opacity = math.sin(t * math.pi).clamp(0.0, 1.0);

        bubblePaint.color = Colors.white.withValues(alpha: opacity * 0.75);
        canvas.drawCircle(Offset(x, y), radius, bubblePaint);
      }
    } else {
      // Rising authentic warm steam curves
      final steamPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.2;

      for (int i = 0; i < 3; i++) {
        final t = (progress + (i * 0.33)) % 1.0;
        final startX = size.width * 0.35 + (i * 26);
        final opacity = (1.0 - t).clamp(0.0, 0.7);

        steamPaint.color = Colors.white.withValues(alpha: opacity * 0.45);

        final path = Path();
        path.moveTo(startX, size.height);
        path.cubicTo(
          startX - 15 + math.sin(t * math.pi * 2) * 10,
          size.height * 0.65,
          startX + 15 - math.sin(t * math.pi * 2) * 10,
          size.height * 0.35,
          startX,
          size.height * (1.0 - t) * 0.6,
        );

        canvas.drawPath(path, steamPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SteamOrParticlesPainter oldDelegate) => true;
}
