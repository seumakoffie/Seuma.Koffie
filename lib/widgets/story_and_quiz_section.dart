// lib/widgets/story_and_quiz_section.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../theme/app_theme.dart';
import 'product_dialog.dart';

class StoryAndQuizSection extends StatefulWidget {
  const StoryAndQuizSection({super.key});

  @override
  State<StoryAndQuizSection> createState() => _StoryAndQuizSectionState();
}

class _StoryAndQuizSectionState extends State<StoryAndQuizSection>
    with SingleTickerProviderStateMixin {
  String _selectedTaste = 'creamy'; // 'creamy' | 'bold' | 'fruity'
  int _activeStoryStep = 0;
  late AnimationController _storyAnimController;

  @override
  void initState() {
    super.initState();
    _storyAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _storyAnimController.dispose();
    super.dispose();
  }

  List<MenuItem> get _recommendedItems {
    if (_selectedTaste == 'bold') {
      return kMenuItems.where((i) => i.categorySlug == 'espresso' || i.categorySlug == 'sanger').take(3).toList();
    } else if (_selectedTaste == 'fruity') {
      return kMenuItems.where((i) => i.categorySlug == 'squash' || i.name.contains('Peach') || i.name.contains('Lemon')).take(3).toList();
    } else {
      return kMenuItems.where((i) => i.categorySlug == 'susu' || i.categorySlug == 'latte' || i.categorySlug == 'matcha').take(3).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : 16,
          vertical: 36,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. STORYLINE: DARI BIJI KE CANGKIR
            // ==========================================
            Container(
              padding: EdgeInsets.all(isDesktop ? 36 : 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppColors.softShadow,
                border: Border.all(color: AppColors.caramel.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.caramel.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'FILOSOFI SEUMA',
                          style: TextStyle(
                            color: AppColors.caramel,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dari Biji Pilihan ke Cangkir Sempurnamu',
                    style: TextStyle(
                      fontSize: isDesktop ? 26 : 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Perjalanan autentik setiap tetes kopi Seuma yang diseduh dengan teknik Sanger tradisional dan standar higienis modern.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.45),
                  ),
                  const SizedBox(height: 18),

                  // ── INTERACTIVE STEP PROGRESS CONNECTOR BAR ───────────────
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.caramel.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: List.generate(4, (i) {
                        final isPassed = i <= _activeStoryStep;
                        final isCurrent = i == _activeStoryStep;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeStoryStep = i),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isPassed
                                        ? const LinearGradient(
                                            colors: [AppColors.caramel, AppColors.gold],
                                          )
                                        : null,
                                    color: !isPassed ? Colors.grey.shade300 : null,
                                    boxShadow: isCurrent
                                        ? [
                                            BoxShadow(
                                              color: AppColors.caramel.withValues(alpha: 0.5),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '0${i + 1}',
                                      style: TextStyle(
                                        color: isPassed ? Colors.white : Colors.black54,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                if (i < 3)
                                  Expanded(
                                    child: Container(
                                      height: 3,
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      decoration: BoxDecoration(
                                        color: i < _activeStoryStep ? AppColors.caramel : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ── 4-STEP ANIMATED GRID ──────────────────────────────────
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 800;
                      final isMedium = constraints.maxWidth > 480;
                      final cols = isWide ? 4 : (isMedium ? 2 : 1);

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: cols,
                        childAspectRatio: isWide ? 0.76 : (isMedium ? 0.95 : 1.45),
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        children: [
                          _buildAnimatedStoryCard(
                            stepIndex: 0,
                            stepNum: '01',
                            title: 'Biji Pilihan Gayo',
                            desc: 'Petik merah matang dari perkebunan dataran tinggi Takengon Aceh.',
                            badge: 'ORGANIK',
                            themeColor: const Color(0xFF2E7D32),
                          ),
                          _buildAnimatedStoryCard(
                            stepIndex: 1,
                            stepNum: '02',
                            title: 'Roasting Artisanal',
                            desc: 'Profil sangrai medium-dark beraroma floral, kakao, & karamel alami.',
                            badge: 'MEDIUM-DARK',
                            themeColor: const Color(0xFFD84315),
                          ),
                          _buildAnimatedStoryCard(
                            stepIndex: 2,
                            stepNum: '03',
                            title: 'Tarikan Sanger Asli',
                            desc: 'Teknik tuang tarikan khas demi tekstur lembut creamy & crema tebal.',
                            badge: 'AUTHENTIC',
                            themeColor: const Color(0xFFB87333),
                          ),
                          _buildAnimatedStoryCard(
                            stepIndex: 3,
                            stepNum: '04',
                            title: 'Kemasan Kilat & Higienis',
                            desc: 'Penyajian steril dalam cup tebal, siap antar kilat 15-20 menit se-Lhokseumawe.',
                            badge: '15-20 MNT',
                            themeColor: const Color(0xFF1565C0),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ==========================================
            // 2. INTERACTIVE TASTE QUIZ
            // ==========================================
            Container(
              padding: EdgeInsets.all(isDesktop ? 36 : 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.espresso,
                    const Color(0xFF2E1505),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.espresso.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'PENCARI KOPI PAS (TASTE QUIZ)',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: isDesktop ? 11 : 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bingung Mau Minum Apa Hari Ini?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 26 : 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih suasana hatimu, dan sistem kami akan merekomendasikan racikan yang paling pas.',
                    style: TextStyle(color: AppColors.cream.withValues(alpha: 0.8), fontSize: 12.5),
                  ),

                  const SizedBox(height: 20),

                  // Question 1: Taste Profile
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _buildTasteOption('creamy', '🧋 Manis & Creamy', _selectedTaste == 'creamy'),
                      _buildTasteOption('bold', '☕ Pekat & Kuat', _selectedTaste == 'bold'),
                      _buildTasteOption('fruity', '🍊 Segar Tropis & Soda', _selectedTaste == 'fruity'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Recommended Items Result
                  Text(
                    'Rekomendasi Untukmu:',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _recommendedItems.map((item) {
                      return InkWell(
                        onTap: () => ProductDialog.show(context, item),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: isDesktop ? 240 : double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.caramel.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              item.hasImage
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        item.resolvedImagePath!,
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Text(item.iconEmoji, style: const TextStyle(fontSize: 26)),
                                      ),
                                    )
                                  : Text(item.iconEmoji, style: const TextStyle(fontSize: 26)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      item.category,
                                      style: TextStyle(
                                        color: AppColors.cream.withValues(alpha: 0.7),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.caramel,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Pesan',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStoryCard({
    required int stepIndex,
    required String stepNum,
    required String title,
    required String desc,
    required String badge,
    required Color themeColor,
  }) {
    final isSelected = _activeStoryStep == stepIndex;

    return AnimatedBuilder(
      animation: _storyAnimController,
      builder: (context, _) {
        final progress = _storyAnimController.value;

        return GestureDetector(
          onTap: () => setState(() => _activeStoryStep = stepIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : const Color(0xFFFBF8F2),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected ? AppColors.caramel : AppColors.caramel.withValues(alpha: 0.18),
                width: isSelected ? 2.2 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.caramel.withValues(alpha: 0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Bar: Badge on Left + Step Number on Right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: themeColor.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    Text(
                      stepNum,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? AppColors.caramel : Colors.black26,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 2. Dedicated Wide Animated Illustration Stage (Height: 96px)
                Container(
                  height: 96,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        themeColor.withValues(alpha: 0.15),
                        themeColor.withValues(alpha: 0.05),
                        Colors.white.withValues(alpha: 0.6),
                      ],
                    ),
                    border: Border.all(
                      color: themeColor.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomPaint(
                      painter: _getStepPainter(stepIndex, progress, themeColor),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Title & Description
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? AppColors.espresso : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? AppColors.espresso.withValues(alpha: 0.85) : AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  CustomPainter _getStepPainter(int stepIndex, double progress, Color themeColor) {
    switch (stepIndex) {
      case 0:
        return _SproutParticlePainter(progress: progress, color: themeColor);
      case 1:
        return _FlameParticlePainter(progress: progress, color: themeColor);
      case 2:
        return _PouringStreamPainter(progress: progress, color: themeColor);
      case 3:
      default:
        return _DeliverySpeedPainter(progress: progress, color: themeColor);
    }
  }

  Widget _buildTasteOption(String id, String label, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedTaste = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.caramel : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// ── ANIMATED STEP 01 PAINTER: Lush Gayo Coffee Branch & Cherries ─────────
class _SproutParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  _SproutParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sway = math.sin(progress * 2 * math.pi) * 4;

    // 1. Soft plantation mountain backdrop hills
    final hillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.18),
          color.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final hillPath = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.65)
      ..quadraticBezierTo(w * 0.25, h * 0.45, w * 0.55, h * 0.6)
      ..quadraticBezierTo(w * 0.8, h * 0.72, w, h * 0.5)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    // 2. Coffee Tree Branch Stem
    final branchPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final branchPath = Path()
      ..moveTo(w * 0.1, h * 0.8)
      ..quadraticBezierTo(w * 0.4, h * 0.55, w * 0.85, h * 0.45 + (sway * 0.4));
    canvas.drawPath(branchPath, branchPaint);

    // 3. Ripe Red Gayo Coffee Cherries (Spherical 3D shading)
    final cherryCenters = [
      Offset(w * 0.42, h * 0.58),
      Offset(w * 0.55, h * 0.50),
      Offset(w * 0.66, h * 0.48),
    ];

    for (int i = 0; i < cherryCenters.length; i++) {
      final c = cherryCenters[i];
      final r = 9.0 + (i % 2) * 1.5;

      final cherryPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: const [
            Color(0xFFFF5252), // Bright cherry shine
            Color(0xFFD32F2F),
            Color(0xFF8B0000), // Dark shadow
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r));

      canvas.drawCircle(c, r, cherryPaint);

      // Specular highlight dot
      final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
      canvas.drawCircle(Offset(c.dx - r * 0.35, c.dy - r * 0.35), 2.0, highlightPaint);
    }

    // 4. Lush Green Coffee Leaves with Sway
    final leafPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Left leaf
    final leaf1 = Path()
      ..moveTo(w * 0.35, h * 0.65)
      ..quadraticBezierTo(w * 0.25 + sway, h * 0.4, w * 0.15 + sway, h * 0.45)
      ..quadraticBezierTo(w * 0.25, h * 0.7, w * 0.35, h * 0.65);
    canvas.drawPath(leaf1, leafPaint);

    // Right leaf
    final leaf2 = Path()
      ..moveTo(w * 0.7, h * 0.48)
      ..quadraticBezierTo(w * 0.8 + sway, h * 0.25, w * 0.92 + sway, h * 0.3)
      ..quadraticBezierTo(w * 0.82, h * 0.55, w * 0.7, h * 0.48);
    canvas.drawPath(leaf2, leafPaint);

    // 5. Floating Sunlight Aroma Sparkles
    final sparklePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final t = (progress + (i * 0.2)) % 1.0;
      final y = h * 0.85 - (t * h * 0.7);
      final x = w * 0.2 + (i * (w * 0.15)) + math.sin(t * math.pi * 3) * 6;
      final alpha = math.sin(t * math.pi).clamp(0.0, 1.0);

      sparklePaint.color = const Color(0xFFFFD54F).withValues(alpha: alpha * 0.85);
      canvas.drawCircle(Offset(x, y), 2.2, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SproutParticlePainter oldDelegate) => true;
}

/// ── ANIMATED STEP 02 PAINTER: Roasting Oven, Dancing Flames & Hot Beans ───
class _FlameParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  _FlameParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.68);
    final flicker = math.sin(progress * 6 * math.pi) * 5;

    // 1. Roaster Oven Drum Ambient Halo
    final ovenPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0.2),
        colors: [
          const Color(0xFFFF6F00).withValues(alpha: 0.35),
          const Color(0xFF3E1700).withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 48));
    canvas.drawCircle(center, 46, ovenPaint);

    // 2. Roaster Drum Grill Frame
    final drumBorder = Paint()
      ..color = const Color(0xFF4E342E).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 70, height: 46),
      math.pi,
      math.pi,
      false,
      drumBorder,
    );

    // 3. Roaring Animated 3-Tier Flames
    // Outer Crimson Flame
    final flameOuter = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFFD84315), Color(0xFFFF5722)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final pathOuter = Path()
      ..moveTo(center.dx - 28, center.dy + 8)
      ..cubicTo(
        center.dx - 32,
        center.dy - 18,
        center.dx - 12 + flicker,
        center.dy - 38,
        center.dx + flicker,
        center.dy - 46,
      )
      ..cubicTo(
        center.dx + 12 - flicker,
        center.dy - 38,
        center.dx + 32,
        center.dy - 18,
        center.dx + 28,
        center.dy + 8,
      )
      ..close();
    canvas.drawPath(pathOuter, flameOuter);

    // Mid Amber Flame
    final flameMid = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFFFFB300), Color(0xFFFFCA28)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final pathMid = Path()
      ..moveTo(center.dx - 18, center.dy + 8)
      ..cubicTo(
        center.dx - 20,
        center.dy - 12,
        center.dx - 6 + flicker * 0.8,
        center.dy - 28,
        center.dx + flicker * 0.6,
        center.dy - 34,
      )
      ..cubicTo(
        center.dx + 6 - flicker * 0.8,
        center.dy - 28,
        center.dx + 20,
        center.dy - 12,
        center.dx + 18,
        center.dy + 8,
      )
      ..close();
    canvas.drawPath(pathMid, flameMid);

    // Inner White-Yellow Heat Core
    final flameCore = Paint()..color = const Color(0xFFFFFDE7);
    canvas.drawCircle(Offset(center.dx, center.dy - 4), 9 + (flicker * 0.4).abs(), flameCore);

    // 4. Tumbling Roasted Coffee Beans
    final beanPaint = Paint()
      ..color = const Color(0xFF3E1F07)
      ..style = PaintingStyle.fill;
    final cleftPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final beanCoords = [
      Offset(center.dx - 34, center.dy - 6 + math.sin(progress * 2 * math.pi) * 3),
      Offset(center.dx + 34, center.dy - 4 - math.sin(progress * 2 * math.pi) * 3),
    ];

    for (final bc in beanCoords) {
      canvas.drawOval(Rect.fromCenter(center: bc, width: 14, height: 10), beanPaint);
      canvas.drawLine(Offset(bc.dx, bc.dy - 4), Offset(bc.dx, bc.dy + 4), cleftPaint);
    }

    // 5. Rising Golden Sparks & Embers
    final emberPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final t = (progress + (i * 0.16)) % 1.0;
      final y = center.dy - 12 - (t * (h * 0.6));
      final x = center.dx - 22 + (i * 8.5) + math.sin(t * math.pi * 3) * 6;
      final alpha = (1.0 - t).clamp(0.0, 1.0);

      emberPaint.color = const Color(0xFFFFD54F).withValues(alpha: alpha * 0.9);
      canvas.drawCircle(Offset(x, y), 2.0, emberPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlameParticlePainter oldDelegate) => true;
}

/// ── ANIMATED STEP 03 PAINTER: Dramatic Barista Pitcher & Sanger Pour ──────
class _PouringStreamPainter extends CustomPainter {
  final double progress;
  final Color color;

  _PouringStreamPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final streamSway = math.sin(progress * 2 * math.pi) * 4;

    // 1. Top Barista Stainless Pitcher (Pouring spout at top right)
    final pitcherPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB0BEC5), Color(0xFFECEFF1), Color(0xFF78909C)],
      ).createShader(Rect.fromLTWH(w * 0.5, 6, 44, 28));

    final pitcherPath = Path()
      ..moveTo(w * 0.58, 8)
      ..lineTo(w * 0.72, 8)
      ..lineTo(w * 0.68, 28)
      ..lineTo(w * 0.52, 28)
      ..lineTo(w * 0.46, 16) // Spout
      ..close();
    canvas.drawPath(pitcherPath, pitcherPaint);

    // 2. Continuous Flowing Liquid Stream (Espresso + Creamy Milk)
    final streamPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF8E7), // Sweet cream top
          Color(0xFF8D6E63),
          Color(0xFF4E342E), // Rich espresso
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final streamPath = Path()
      ..moveTo(w * 0.46, 18)
      ..quadraticBezierTo(
        w * 0.44 + streamSway,
        h * 0.45,
        w * 0.42 - (streamSway * 0.4),
        h * 0.72,
      );
    canvas.drawPath(streamPath, streamPaint);

    // Inner highlight stream
    final innerStream = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(streamPath, innerStream);

    // 3. Bottom Glass Cup with 3 Sanger Layers
    final cupCenter = Offset(w * 0.42, h * 0.78);
    final cupW = 38.0;
    final cupH = 26.0;

    // Glass Cup body
    final cupPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final cupBorder = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final cupRect = Rect.fromCenter(center: cupCenter, width: cupW, height: cupH);
    canvas.drawRRect(RRect.fromRectAndRadius(cupRect, const Radius.circular(6)), cupPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(cupRect, const Radius.circular(6)), cupBorder);

    // Sanger Layers inside cup:
    // Base condensed milk
    final milkPaint = Paint()..color = const Color(0xFFFFF9E6);
    canvas.drawRect(
      Rect.fromLTWH(cupRect.left + 2, cupRect.bottom - 8, cupW - 4, 6),
      milkPaint,
    );
    // Espresso layer
    final espPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawRect(
      Rect.fromLTWH(cupRect.left + 2, cupRect.top + 5, cupW - 4, cupH - 13),
      espPaint,
    );
    // Golden Crema foam top
    final cremaPaint = Paint()..color = const Color(0xFFD7CCC8);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cupCenter.dx, cupRect.top + 4), width: cupW - 4, height: 6),
      cremaPaint,
    );

    // 4. Splashing Droplets & Crema Froth Bubbles
    final dropPaint = Paint()
      ..color = const Color(0xFFFFF8E7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final t = (progress + (i * 0.33)) % 1.0;
      final dx = cupCenter.dx - 14 + (i * 14) + math.sin(t * math.pi) * 6;
      final dy = cupRect.top - (math.sin(t * math.pi) * 12);
      canvas.drawCircle(Offset(dx, dy), 1.8, dropPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PouringStreamPainter oldDelegate) => true;
}

/// ── ANIMATED STEP 04 PAINTER: Sealed Takeaway Cup, Steam & Delivery Speed ──
class _DeliverySpeedPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DeliverySpeedPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.55, h * 0.58);

    // 1. Dynamic Gliding Delivery Speed Streaks (Left to Right)
    final streakPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final streakYOffsets = [h * 0.25, h * 0.45, h * 0.7, h * 0.85];
    final streakLengths = [28.0, 44.0, 36.0, 20.0];

    for (int i = 0; i < streakYOffsets.length; i++) {
      final t = (progress + (i * 0.25)) % 1.0;
      final startX = (t * (w * 0.85)) - 10;
      final y = streakYOffsets[i];
      final alpha = math.sin(t * math.pi).clamp(0.0, 1.0);

      streakPaint
        ..color = color.withValues(alpha: alpha * 0.75)
        ..strokeWidth = 2.0 + (i % 2);

      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + streakLengths[i], y),
        streakPaint,
      );
    }

    // 2. Modern Seuma Takeaway Cup with Lid & Sleeve
    final cupW = 34.0;
    final cupH = 46.0;

    // Cup Body
    final cupPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF261205), Color(0xFF1B0B04)],
      ).createShader(Rect.fromCenter(center: center, width: cupW, height: cupH));

    final cupPath = Path()
      ..moveTo(center.dx - cupW * 0.5, center.dy - cupH * 0.5)
      ..lineTo(center.dx + cupW * 0.5, center.dy - cupH * 0.5)
      ..lineTo(center.dx + cupW * 0.38, center.dy + cupH * 0.5)
      ..lineTo(center.dx - cupW * 0.38, center.dy + cupH * 0.5)
      ..close();
    canvas.drawPath(cupPath, cupPaint);

    // Thermal Kraft Sleeve
    final sleevePaint = Paint()
      ..color = const Color(0xFFD48B38)
      ..style = PaintingStyle.fill;
    final sleeveRect = Rect.fromCenter(center: Offset(center.dx, center.dy + 2), width: cupW * 0.95, height: 18);
    canvas.drawRRect(RRect.fromRectAndRadius(sleeveRect, const Radius.circular(3)), sleevePaint);

    // Cup Lid (Blue / White Hygienic Cap)
    final lidPaint = Paint()..color = const Color(0xFF1565C0);
    final lidRect = Rect.fromCenter(center: Offset(center.dx, center.dy - cupH * 0.5 - 3), width: cupW + 6, height: 8);
    canvas.drawRRect(RRect.fromRectAndRadius(lidRect, const Radius.circular(4)), lidPaint);

    // Tamper-evident Seal Sticker
    final sealPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawRect(Rect.fromLTWH(center.dx - 3, center.dy - cupH * 0.5 - 5, 6, 12), sealPaint);

    // 3. Warm Rising Steam Waves
    final steamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 2; i++) {
      final t = (progress + (i * 0.5)) % 1.0;
      final steamY = center.dy - cupH * 0.5 - 10 - (t * 18);
      final steamX = center.dx - 4 + (i * 8) + math.sin(t * math.pi * 2) * 3;
      canvas.drawCircle(Offset(steamX, steamY), 1.4, steamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DeliverySpeedPainter oldDelegate) => true;
}

