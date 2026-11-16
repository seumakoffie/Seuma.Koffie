// lib/widgets/pro/about_section_v3.dart
// About / Filosofi Section with animated stats & timeline for Seuma.Koffie v3.0
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pro/scroll_reveal.dart';
import 'sanger_cup_widget.dart';

class AboutSectionV3 extends StatefulWidget {
  const AboutSectionV3({super.key});

  @override
  State<AboutSectionV3> createState() => _AboutSectionV3State();
}

class _AboutSectionV3State extends State<AboutSectionV3>
    with TickerProviderStateMixin {
  late AnimationController _statsController;
  final List<_CounterData> _stats = [
    _CounterData('50+', 'Varian Menu', Icons.coffee_rounded),
    _CounterData('1K+', 'Pelanggan Setia', Icons.favorite_rounded),
    _CounterData('4', 'Kecamatan Dijangkau', Icons.location_on_rounded),
    _CounterData('100%', 'Biji Kopi Aceh', Icons.eco_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDesktop = sw > 900;

    return Container(
      color: const Color(0xFFFBF6EE),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 20,
        vertical: 72,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // ─── TOP BRAND INTRO ───────────────────────────────────────
              isDesktop
                  ? _buildDesktopIntro()
                  : _buildMobileIntro(),

              const SizedBox(height: 80),

              // ─── ANIMATED STATS COUNTER ───────────────────────────────
              ScrollReveal(
                effect: RevealEffect.fadeUp,
                child: _buildStatsRow(isDesktop),
              ),

              const SizedBox(height: 72),

              // ─── JOURNEY TIMELINE ────────────────────────────────────
              ScrollReveal(
                effect: RevealEffect.fadeUp,
                delay: const Duration(milliseconds: 150),
                child: _buildTimeline(isDesktop),
              ),

              const SizedBox(height: 72),

              // ─── BARISTA HIGHLIGHTS ───────────────────────────────────
              ScrollReveal(
                effect: RevealEffect.fadeUp,
                delay: const Duration(milliseconds: 200),
                child: _buildBaristaSection(isDesktop),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopIntro() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left text
        Expanded(
          flex: 6,
          child: ScrollReveal(
            effect: RevealEffect.fadeRight,
            child: _buildIntroText(),
          ),
        ),
        const SizedBox(width: 60),
        // Right visual: Cup Sanger with parallax feel
        Expanded(
          flex: 5,
          child: ScrollReveal(
            effect: RevealEffect.fadeLeft,
            delay: const Duration(milliseconds: 200),
            child: Center(
              child: SangerCupWidget(size: 300, isIced: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScrollReveal(effect: RevealEffect.fadeUp, child: _buildIntroText()),
        const SizedBox(height: 32),
        ScrollReveal(
          effect: RevealEffect.zoomIn,
          delay: const Duration(milliseconds: 200),
          child: Center(child: SangerCupWidget(size: 220, isIced: false)),
        ),
      ],
    );
  }

  Widget _buildIntroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.caramel.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'FILOSOFI SEUMA',
            style: TextStyle(
              color: AppColors.caramel,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Dari Biji Pilihan\nke Cangkir Sempurnamu',
          style: TextStyle(
            color: AppColors.espresso,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Seuma.Koffie lahir dari kecintaan mendalam terhadap kopi Aceh yang otentik. Nama "Seuma" terinspirasi dari jiwa Lhokseumawe — kota yang dikenal dengan semangat, kebersamaan, dan cita rasa kopi yang tak tertandingi.',
          style: TextStyle(
            color: AppColors.espresso.withValues(alpha: 0.7),
            fontSize: 15,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Setiap tetes yang kami seduh adalah manifestasi dari tradisi panjang perkebunan Gayo yang bertemu dengan standar penyajian modern. Kopi Sanger bukan sekadar minuman — ia adalah identitas, cerita, dan kehangatan Aceh dalam secangkir.',
          style: TextStyle(
            color: AppColors.espresso.withValues(alpha: 0.6),
            fontSize: 14,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            _buildPillarBadge(Icons.eco_rounded, 'Biji Pilihan Gayo'),
            const SizedBox(width: 10),
            _buildPillarBadge(Icons.local_cafe_rounded, 'Resep Sanger Otentik'),
          ],
        ),
      ],
    );
  }

  Widget _buildPillarBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.caramel.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.caramel.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.caramel),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.caramel,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 36.0 : 24.0),
      decoration: BoxDecoration(
        color: AppColors.espresso,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.espresso.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _stats
                  .asMap()
                  .entries
                  .map((e) => _buildStatCard(e.value, e.key * 100))
                  .toList(),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - 16) / 2;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _stats
                      .asMap()
                      .entries
                      .map((e) => SizedBox(
                            width: cardWidth > 120 ? cardWidth : constraints.maxWidth,
                            child: _buildStatCard(e.value, e.key * 100),
                          ))
                      .toList(),
                );
              },
            ),
    );
  }

  Widget _buildStatCard(_CounterData stat, int delay) {
    return ScrollReveal(
      effect: RevealEffect.zoomIn,
      delay: Duration(milliseconds: delay),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.caramel.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(stat.icon, color: AppColors.gold, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            stat.value,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.cream.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(bool isDesktop) {
    final events = [
      _TimelineEvent('2024', 'Cikal Bakal Seuma', 'Resep Sanger otentik dikembangkan dari tradisi kopi Aceh di dataran tinggi Gayo dengan standar penyajian higienis modern.', '☕'),
      _TimelineEvent('2025', 'Lahir di Lhokseumawe', 'Seuma.Koffie resmi hadir melayani penikmat kopi di Kota Lhokseumawe, dimulai dari kecamatan Banda Sakti dan Muara Dua.', '🌱'),
      _TimelineEvent('2026', 'Ekspansi & Digitalisasi', 'Jangkauan diperluas ke 4 kecamatan. Platform digital diluncurkan untuk memudahkan pemesanan online dengan pengantaran cepat 15–20 menit.', '🚀'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.caramel.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'PERJALANAN KAMI',
            style: TextStyle(color: AppColors.caramel, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Timeline Seuma.Koffie',
          style: TextStyle(color: AppColors.espresso, fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 32),
        isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: events.asMap().entries.map((e) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: e.key < events.length - 1 ? 20 : 0),
                      child: ScrollReveal(
                        effect: RevealEffect.fadeUp,
                        delay: Duration(milliseconds: e.key * 150),
                        child: _buildTimelineCard(e.value, e.key),
                      ),
                    ),
                  );
                }).toList(),
              )
            : Column(
                children: events.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ScrollReveal(
                    effect: RevealEffect.fadeUp,
                    delay: Duration(milliseconds: e.key * 100),
                    child: _buildTimelineCard(e.value, e.key),
                  ),
                )).toList(),
              ),
      ],
    );
  }

  Widget _buildTimelineCard(_TimelineEvent event, int index) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.caramel.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(event.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.caramel,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event.year,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            event.title,
            style: const TextStyle(color: AppColors.espresso, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: TextStyle(color: AppColors.espresso.withValues(alpha: 0.65), fontSize: 12.5, height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _buildBaristaSection(bool isDesktop) {
    final baristas = [
      _BaristaData('Kepala Barista', 'Ahli Sanger Aceh & Kopi Gayo', '🧑‍🍳', ['Sanger Specialist', 'Coffee Q-Grader']),
      _BaristaData('Barista Senior', 'Spesialis Kopi Susu & Latte Art', '👩‍🍳', ['Latte Art Pro', '5+ Tahun Pengalaman']),
      _BaristaData('Quality Control', 'Penjaga Standar Rasa & Kebersihan', '🧑‍💼', ['BPOM Certified', 'Higienis Expert']),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.caramel.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'TIM KAMI',
                    style: TextStyle(color: AppColors.caramel, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Barista & Tim Seuma',
                  style: TextStyle(color: AppColors.espresso, fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 28),
        isDesktop
            ? Row(
                children: baristas.asMap().entries.map((e) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: e.key < baristas.length - 1 ? 16 : 0),
                    child: ScrollReveal(
                      effect: RevealEffect.fadeUp,
                      delay: Duration(milliseconds: e.key * 120),
                      child: _buildBaristaCard(e.value),
                    ),
                  ),
                )).toList(),
              )
            : Column(
                children: baristas.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildBaristaCard(b),
                )).toList(),
              ),
      ],
    );
  }

  Widget _buildBaristaCard(_BaristaData b) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.caramel.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.cream,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.caramel.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Text(b.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 14),
          Text(b.role, style: const TextStyle(color: AppColors.espresso, fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 4),
          Text(b.specialty, style: TextStyle(color: AppColors.espresso.withValues(alpha: 0.6), fontSize: 12)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: b.badges.map((badge) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.caramel.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(badge, style: const TextStyle(color: AppColors.caramel, fontSize: 10, fontWeight: FontWeight.w700)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _CounterData {
  final String value;
  final String label;
  final IconData icon;
  _CounterData(this.value, this.label, this.icon);
}

class _TimelineEvent {
  final String year;
  final String title;
  final String description;
  final String emoji;
  _TimelineEvent(this.year, this.title, this.description, this.emoji);
}

class _BaristaData {
  final String role;
  final String specialty;
  final String emoji;
  final List<String> badges;
  _BaristaData(this.role, this.specialty, this.emoji, this.badges);
}
