// lib/widgets/pro/sanger_cup_widget.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Artisanal Cup Sanger Khas Aceh
/// Rendered with pure Flutter CustomPainter featuring:
/// - 3 authentic layers (Condensed Milk, Dark Sanger Brew, Aerated Crema Foam)
/// - Animated rising dynamic steam trails (in Hot mode)
/// - Condensation droplets & floating ice cubes (in Iced mode)
/// - Specular glass highlights and glass base refraction
class SangerCupWidget extends StatefulWidget {
  final double size;
  final bool isIced;
  final ValueChanged<bool>? onToggleThermal;

  const SangerCupWidget({
    super.key,
    this.size = 280,
    this.isIced = false,
    this.onToggleThermal,
  });

  @override
  State<SangerCupWidget> createState() => _SangerCupWidgetState();
}

class _SangerCupWidgetState extends State<SangerCupWidget> with TickerProviderStateMixin {
  late AnimationController _steamController;
  late AnimationController _bubbleController;
  late AnimationController _bobbingController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // Steam & dynamic fluid animation
    _steamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    // Crema bubble micro-animation
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);

    // Harmonic float/bobbing
    _bobbingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _steamController.dispose();
    _bubbleController.dispose();
    _bobbingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize = widget.size;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main Cup Container with subtle bobbing
          AnimatedBuilder(
            animation: Listenable.merge([_steamController, _bubbleController, _bobbingController]),
            builder: (context, child) {
              final bobbingOffset = math.sin(_bobbingController.value * math.pi) * 6;
              final hoverScale = _isHovered ? 1.04 : 1.0;

              return Transform.scale(
                scale: hoverScale,
                child: Transform.translate(
                  offset: Offset(0, -bobbingOffset),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ambient Glow behind the cup
                      Container(
                        width: effectiveSize * 0.95,
                        height: effectiveSize * 0.95,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.caramel.withValues(alpha: widget.isIced ? 0.22 : 0.40),
                              AppColors.gold.withValues(alpha: widget.isIced ? 0.15 : 0.25),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),

                      // Shadow on saucer/pedestal
                      Positioned(
                        bottom: 4,
                        child: Container(
                          width: effectiveSize * 0.65,
                          height: 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.elliptical(effectiveSize * 0.65, 18)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 22,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // CustomPainter Cup Sanger Canvas
                      CustomPaint(
                        size: Size(effectiveSize, effectiveSize * 1.15),
                        painter: _SangerCupPainter(
                          steamProgress: _steamController.value,
                          bubbleProgress: _bubbleController.value,
                          isIced: widget.isIced,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // Thermal Switch Pill (HOT / ICED)
          if (widget.onToggleThermal != null)
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThermalTab(
                    title: 'HOT SANGER',
                    icon: Icons.local_fire_department_rounded,
                    isActive: !widget.isIced,
                    activeColor: AppColors.caramel,
                    onTap: () => widget.onToggleThermal!(false),
                  ),
                  _buildThermalTab(
                    title: 'ICED SANGER',
                    icon: Icons.ac_unit_rounded,
                    isActive: widget.isIced,
                    activeColor: Colors.lightBlue.shade400,
                    onTap: () => widget.onToggleThermal!(true),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThermalTab({
    required String title,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isActive ? Colors.white : AppColors.cream.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.cream.withValues(alpha: 0.7),
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Canvas Painter for Cup Sanger Aceh
class _SangerCupPainter extends CustomPainter {
  final double steamProgress;
  final double bubbleProgress;
  final bool isIced;

  _SangerCupPainter({
    required this.steamProgress,
    required this.bubbleProgress,
    required this.isIced,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cup dimensions proportional to canvas
    final cupTop = h * 0.32;
    final cupBottom = h * 0.90;
    final cupHeight = cupBottom - cupTop;

    final cupTopWidth = w * 0.62;
    final cupBottomWidth = w * 0.44;

    final leftTop = (w - cupTopWidth) / 2;
    final rightTop = leftTop + cupTopWidth;
    final leftBottom = (w - cupBottomWidth) / 2;
    final rightBottom = leftBottom + cupBottomWidth;

    // Draw Steam if HOT
    if (!isIced) {
      _paintRisingSteam(canvas, size, cupTop, leftTop, rightTop);
    }

    // Saucer / Plate underneath
    _paintSaucer(canvas, w, cupBottom, cupBottomWidth);

    // 1. Cup Outline Path (Trapezoid with rounded corners)
    final cupPath = Path();
    cupPath.moveTo(leftTop, cupTop);
    cupPath.lineTo(rightTop, cupTop);
    cupPath.quadraticBezierTo(rightBottom + 6, cupBottom - 4, rightBottom, cupBottom);
    cupPath.quadraticBezierTo(w / 2, cupBottom + 6, leftBottom, cupBottom);
    cupPath.quadraticBezierTo(leftBottom - 6, cupBottom - 4, leftTop, cupTop);
    cupPath.close();

    // 2. Liquid Region (Inside Glass)
    canvas.save();
    canvas.clipPath(cupPath);

    // Glass Background Dark Tint
    final glassBgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.08),
          Colors.black.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, cupTop, w, cupHeight));
    canvas.drawRect(Rect.fromLTWH(0, cupTop, w, cupHeight), glassBgPaint);

    // ==========================================
    // LAYER 1: Condensed Milk (Susu Kental Manis)
    // 20% from bottom of cup
    // ==========================================
    final milkTopY = cupBottom - (cupHeight * 0.22);
    final milkRect = Rect.fromLTWH(0, milkTopY, w, cupBottom - milkTopY + 10);
    final milkPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFDE8BC), // Creamy sweet condensed milk top
          Color(0xFFF7D99A), // Rich golden condensed milk
          Color(0xFFEBC77D), // Base condensed milk
        ],
      ).createShader(milkRect);
    canvas.drawRect(milkRect, milkPaint);

    // Wave blend transition between milk and coffee
    final milkWavePath = Path();
    milkWavePath.moveTo(leftBottom - 10, milkTopY);
    for (double x = leftBottom - 10; x <= rightBottom + 10; x += 10) {
      final waveY = milkTopY + math.sin((x / 20) + (bubbleProgress * math.pi * 2)) * 2.5;
      milkWavePath.lineTo(x, waveY);
    }
    milkWavePath.lineTo(rightBottom + 20, cupBottom + 10);
    milkWavePath.lineTo(leftBottom - 20, cupBottom + 10);
    milkWavePath.close();
    canvas.drawPath(
      milkWavePath,
      Paint()
        ..color = const Color(0xFFF8DEAA).withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // ==========================================
    // LAYER 2: Dark Sanger Coffee Extract
    // From milkTop to cremaBottom (55% of height)
    // ==========================================
    final cremaTopY = cupTop + (cupHeight * 0.08);
    final cremaBottomY = cupTop + (cupHeight * 0.22);
    final coffeeRect = Rect.fromLTWH(0, cremaBottomY - 4, w, milkTopY - cremaBottomY + 8);
    final coffeePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF261004), // Deep dark espresso
          Color(0xFF4A1F08), // Rich Robusta Aceh amber
          Color(0xFF6E320F), // Sanger caramelized gradient
          Color(0xFF9E4B17), // Near-milk transition
        ],
        stops: [0.0, 0.4, 0.75, 1.0],
      ).createShader(coffeeRect);
    canvas.drawRect(coffeeRect, coffeePaint);

    // Ice Cubes if ICED
    if (isIced) {
      _paintIceCubes(canvas, w, cupTop, cupHeight);
    }

    // ==========================================
    // LAYER 3: Aerated Crema / Foam Head (Sanger Tarik)
    // 14% of height at the top
    // ==========================================
    final cremaRect = Rect.fromLTWH(0, cremaTopY, w, cremaBottomY - cremaTopY + 4);
    final cremaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE9C590), // Frothy golden crema top
          Color(0xFFD49C56), // Sanger foam core
          Color(0xFF9C5A24), // Froth boundary
        ],
      ).createShader(cremaRect);
    canvas.drawRect(cremaRect, cremaPaint);

    // Foam surface micro-bubbles
    _paintFoamBubbles(canvas, w, cremaTopY, cremaBottomY);

    // Glass Base Refraction (Thick bottom glass)
    final glassBaseRect = Rect.fromLTWH(0, cupBottom - 12, w, 16);
    final glassBasePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.45),
        ],
      ).createShader(glassBaseRect);
    canvas.drawRect(glassBaseRect, glassBasePaint);

    // Glass Vertical Specular Reflection (Left side highlight)
    final specPath = Path();
    specPath.moveTo(leftTop + 10, cupTop + 4);
    specPath.lineTo(leftTop + 24, cupTop + 4);
    specPath.lineTo(leftBottom + 16, cupBottom - 8);
    specPath.lineTo(leftBottom + 8, cupBottom - 8);
    specPath.close();

    final specPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.30),
        ],
      ).createShader(Rect.fromLTWH(0, cupTop, w, cupHeight));
    canvas.drawPath(specPath, specPaint);

    // Secondary soft right rim reflection
    final rightSpecPath = Path();
    rightSpecPath.moveTo(rightTop - 14, cupTop + 8);
    rightSpecPath.lineTo(rightTop - 8, cupTop + 8);
    rightSpecPath.lineTo(rightBottom - 8, cupBottom - 10);
    rightSpecPath.lineTo(rightBottom - 12, cupBottom - 10);
    rightSpecPath.close();
    canvas.drawPath(
      rightSpecPath,
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );

    canvas.restore(); // Restore unclipped

    // Condensation droplets if ICED
    if (isIced) {
      _paintCondensationDroplets(canvas, w, cupTop, cupBottom, leftTop, rightTop, leftBottom, rightBottom);
    }

    // Glass Outer Rim Outline & Glass Lip
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.7),
          Colors.white.withValues(alpha: 0.2),
          AppColors.gold.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.6),
        ],
      ).createShader(Rect.fromLTWH(0, cupTop, w, cupHeight));
    canvas.drawPath(cupPath, rimPaint);

    // Glass Top Lip Ellipse
    final lipRect = Rect.fromCenter(
      center: Offset(w / 2, cupTop),
      width: cupTopWidth,
      height: 10,
    );
    canvas.drawOval(
      lipRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Colors.white.withValues(alpha: 0.65),
    );
  }

  // Draw Rising Dynamic Steam Trails
  void _paintRisingSteam(Canvas canvas, Size size, double cupTop, double leftTop, double rightTop) {
    final centerX = size.width / 2;

    for (int i = -1; i <= 1; i++) {
      final steamPath = Path();
      final steamPhase = (steamProgress + (i * 0.33)) % 1.0;
      final startX = centerX + (i * 26);
      final steamY = cupTop - 12;

      final p0 = Offset(startX, steamY);
      final p1 = Offset(
        startX + math.sin((steamPhase * math.pi * 2) + i) * 18,
        steamY - 35,
      );
      final p2 = Offset(
        startX - math.cos((steamPhase * math.pi * 2) + i) * 22,
        steamY - 75,
      );
      final p3 = Offset(
        startX + math.sin((steamPhase * math.pi * 2) + (i * 1.5)) * 14,
        steamY - 110,
      );

      steamPath.moveTo(p0.dx, p0.dy);
      steamPath.cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

      final steamAlpha = (1.0 - steamPhase) * 0.45;
      final steamPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 - (steamPhase * 2.0)
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..color = Colors.white.withValues(alpha: steamAlpha.clamp(0.0, 1.0));

      canvas.drawPath(steamPath, steamPaint);
    }
  }

  // Draw Ceramic/Glass Saucer beneath the Sanger Glass
  void _paintSaucer(Canvas canvas, double w, double cupBottom, double cupBottomWidth) {
    final saucerWidth = cupBottomWidth * 1.55;
    final saucerRect = Rect.fromCenter(
      center: Offset(w / 2, cupBottom + 4),
      width: saucerWidth,
      height: 16,
    );

    // Saucer Base
    final saucerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4A2311),
          const Color(0xFF281005),
          const Color(0xFF140802),
        ],
      ).createShader(saucerRect);
    canvas.drawOval(saucerRect, saucerPaint);

    // Saucer Rim Highlight
    final saucerRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = AppColors.gold.withValues(alpha: 0.55);
    canvas.drawOval(saucerRect, saucerRim);
  }

  // Draw Micro Crema Bubbles
  void _paintFoamBubbles(Canvas canvas, double w, double cremaTopY, double cremaBottomY) {
    final bubblePaint = Paint()..color = const Color(0xFFFFF0D0).withValues(alpha: 0.45);
    final offsets = [
      Offset(w * 0.42, cremaTopY + 6),
      Offset(w * 0.54, cremaTopY + 8),
      Offset(w * 0.36, cremaTopY + 14),
      Offset(w * 0.62, cremaTopY + 12),
      Offset(w * 0.48, cremaBottomY - 4),
    ];

    for (final offset in offsets) {
      canvas.drawCircle(offset, 1.8 + (bubbleProgress * 0.7), bubblePaint);
    }
  }

  // Draw Translucent Ice Cubes in Glass
  void _paintIceCubes(Canvas canvas, double w, double cupTop, double cupHeight) {
    final icePaint = Paint()
      ..color = Colors.lightBlue.shade100.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    final iceBorder = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final iceCenters = [
      Offset(w * 0.42, cupTop + (cupHeight * 0.35)),
      Offset(w * 0.56, cupTop + (cupHeight * 0.42)),
      Offset(w * 0.46, cupTop + (cupHeight * 0.55)),
    ];

    for (int i = 0; i < iceCenters.length; i++) {
      canvas.save();
      canvas.translate(iceCenters[i].dx, iceCenters[i].dy);
      canvas.rotate((i * 0.35) - 0.2);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 28, height: 26),
        const Radius.circular(5),
      );
      canvas.drawRRect(rrect, icePaint);
      canvas.drawRRect(rrect, iceBorder);
      canvas.restore();
    }
  }

  // Draw Realistic Condensation Water Droplets
  void _paintCondensationDroplets(
    Canvas canvas,
    double w,
    double cupTop,
    double cupBottom,
    double leftTop,
    double rightTop,
    double leftBottom,
    double rightBottom,
  ) {
    final dropPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    final dropPositions = [
      Offset(leftTop + 18, cupTop + 45),
      Offset(leftTop + 24, cupTop + 85),
      Offset(leftTop + 16, cupTop + 120),
      Offset(rightTop - 20, cupTop + 55),
      Offset(rightTop - 25, cupTop + 95),
      Offset(w * 0.50, cupTop + 70),
      Offset(w * 0.42, cupTop + 110),
      Offset(w * 0.58, cupTop + 130),
    ];

    for (final pos in dropPositions) {
      canvas.drawCircle(pos, 2.2, dropPaint);
      // Small highlight on droplet
      canvas.drawCircle(
        pos - const Offset(0.6, 0.6),
        0.8,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SangerCupPainter oldDelegate) {
    return oldDelegate.steamProgress != steamProgress ||
        oldDelegate.bubbleProgress != bubbleProgress ||
        oldDelegate.isIced != isIced;
  }
}

