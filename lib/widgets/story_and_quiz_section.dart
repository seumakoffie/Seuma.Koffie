// lib/widgets/story_and_quiz_section.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                        childAspectRatio: isWide ? 0.95 : (isMedium ? 1.35 : 2.1),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
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
                              Text(item.iconEmoji, style: const TextStyle(fontSize: 26)),
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

            // ==========================================
            // 3. PROMO VOUCHER BANNER
            // ==========================================
            Container(
              padding: EdgeInsets.all(isDesktop ? 28 : 18),
              decoration: BoxDecoration(
                gradient: AppColors.caramelGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.caramel.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Voucher Diskon Spesial: SEUMAFIRST',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dapatkan potongan Rp 15.000 untuk pesanan pertamamu di web Seuma!',
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: 'SEUMAFIRST'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kode voucher SEUMAFIRST disalin!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.espresso,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Salin Kode', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
            ),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.caramel : AppColors.caramel.withValues(alpha: 0.15),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.caramel.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Header Row: Animated Icon + Step Num + Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Moving Visual CustomPaint Canvas
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CustomPaint(
                          painter: _getStepPainter(stepIndex, progress, themeColor),
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: themeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                  ],
                ),

                const SizedBox(height: 12),

                // Title & Description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? AppColors.espresso : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isSelected ? AppColors.espresso.withValues(alpha: 0.8) : AppColors.textMuted,
                        height: 1.45,
                      ),
                    ),
                  ],
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

/// ── ANIMATED STEP 01 PAINTER: Sprouting Gayo Coffee Seed & Foliage ───────
class _SproutParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  _SproutParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.62);
    final sway = math.sin(progress * 2 * math.pi) * 3;

    // Coffee Bean Base
    final beanPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 22, height: 16),
      beanPaint,
    );

    // Bean Center Line
    final centerLine = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx, center.dy - 6),
      Offset(center.dx, center.dy + 6),
      centerLine,
    );

    // Sprouting Leaf with Sway
    final leafPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    leafPath.moveTo(center.dx, center.dy - 6);
    leafPath.quadraticBezierTo(
      center.dx + 8 + sway,
      center.dy - 18,
      center.dx + sway,
      center.dy - 22,
    );
    leafPath.quadraticBezierTo(
      center.dx - 8 + sway,
      center.dy - 18,
      center.dx,
      center.dy - 6,
    );
    canvas.drawPath(leafPath, leafPaint);

    // Floating green foliage sparkles
    final sparklePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 3; i++) {
      final t = (progress + (i * 0.33)) % 1.0;
      final y = size.height * 0.5 - (t * 16);
      final x = center.dx - 12 + (i * 12) + math.sin(t * math.pi * 2) * 4;
      sparklePaint.color = color.withValues(alpha: (1.0 - t).clamp(0.0, 0.8));
      canvas.drawCircle(Offset(x, y), 1.6, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SproutParticlePainter oldDelegate) => true;
}

/// ── ANIMATED STEP 02 PAINTER: Roasting Flames & Rising Embers ────────────
class _FlameParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  _FlameParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.65);
    final flicker = math.sin(progress * 4 * math.pi) * 3;

    // Outer Orange Flame
    final flamePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFB300), Color(0xFFE65100), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: 20));

    final flamePath = Path();
    flamePath.moveTo(center.dx - 12, center.dy + 6);
    flamePath.cubicTo(
      center.dx - 16,
      center.dy - 8,
      center.dx - 4 + flicker,
      center.dy - 20,
      center.dx + flicker,
      center.dy - 24,
    );
    flamePath.cubicTo(
      center.dx + 6 - flicker,
      center.dy - 18,
      center.dx + 16,
      center.dy - 8,
      center.dx + 12,
      center.dy + 6,
    );
    flamePath.close();
    canvas.drawPath(flamePath, flamePaint);

    // Inner Yellow Core
    final corePaint = Paint()..color = const Color(0xFFFFF176);
    canvas.drawCircle(Offset(center.dx, center.dy), 6 + (flicker * 0.5).abs(), corePaint);

    // Rising Ember Sparks
    final emberPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final t = (progress + (i * 0.25)) % 1.0;
      final y = center.dy - 10 - (t * 20);
      final x = center.dx - 8 + (i * 6) + math.sin(t * math.pi * 3) * 3;
      emberPaint.color = const Color(0xFFFFD54F).withValues(alpha: (1.0 - t).clamp(0.0, 0.9));
      canvas.drawCircle(Offset(x, y), 1.5, emberPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlameParticlePainter oldDelegate) => true;
}

/// ── ANIMATED STEP 03 PAINTER: Sanger Milk Pull & Liquid Wave Stream ──────
class _PouringStreamPainter extends CustomPainter {
  final double progress;
  final Color color;

  _PouringStreamPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final wave = math.sin(progress * 2 * math.pi) * 2.5;

    // Pouring Stream from above
    final streamPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF8E7), Color(0xFF6D4C41)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final streamPath = Path();
    streamPath.moveTo(size.width * 0.5, 4);
    streamPath.quadraticBezierTo(
      size.width * 0.5 + wave,
      size.height * 0.45,
      size.width * 0.5 - (wave * 0.5),
      size.height * 0.75,
    );
    canvas.drawPath(streamPath, streamPaint);

    // Cup Base / Crema Froth at the bottom
    final cremaPaint = Paint()
      ..color = const Color(0xFFD7CCC8)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.8),
        width: 28 + wave.abs() * 2,
        height: 10,
      ),
      cremaPaint,
    );

    // Droplets
    final dropPaint = Paint()
      ..color = const Color(0xFFFFF8E7)
      ..style = PaintingStyle.fill;
    final dropY = (size.height * 0.15 + (progress * 24)) % (size.height * 0.7);
    canvas.drawCircle(Offset(size.width * 0.5 + wave * 0.8, dropY), 1.8, dropPaint);
  }

  @override
  bool shouldRepaint(covariant _PouringStreamPainter oldDelegate) => true;
}

/// ── ANIMATED STEP 04 PAINTER: Sealed Fast Delivery Cup with Speed Lines ──
class _DeliverySpeedPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DeliverySpeedPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.55, size.height * 0.55);

    // Takeaway Sealed Cup Body
    final cupPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cupPath = Path();
    cupPath.moveTo(center.dx - 10, center.dy - 12);
    cupPath.lineTo(center.dx + 10, center.dy - 12);
    cupPath.lineTo(center.dx + 8, center.dy + 14);
    cupPath.lineTo(center.dx - 8, center.dy + 14);
    cupPath.close();
    canvas.drawPath(cupPath, cupPaint);

    // Cup Lid
    final lidPaint = Paint()..color = const Color(0xFF1E88E5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy - 14), width: 24, height: 5),
        const Radius.circular(2),
      ),
      lidPaint,
    );

    // Animated Delivery Speed Lines (left to right)
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      final t = (progress + (i * 0.33)) % 1.0;
      final x = 4 + (t * 14);
      final y = center.dy - 8 + (i * 9);
      canvas.drawLine(Offset(x, y), Offset(x + 10, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DeliverySpeedPainter oldDelegate) => true;
}

