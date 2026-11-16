// lib/widgets/navbar/mega_menu/about_dropdown_panel.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AboutDropdownPanel extends StatelessWidget {
  final VoidCallback onScrollToAbout;
  final VoidCallback onExploreMenu;
  final VoidCallback onScrollToLocation;
  final VoidCallback onClose;

  const AboutDropdownPanel({
    super.key,
    required this.onScrollToAbout,
    required this.onExploreMenu,
    required this.onScrollToLocation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'title': 'Filosofi & Cerita Kami', 'sub': 'Asal usul Kopi Sanger Lhokseumawe'},
      {'title': 'Tim & Barista', 'sub': 'Keahlian seduh manual & modern'},
      {'title': 'Perjalanan 2024-2026', 'sub': 'Milestone & ekspansi Seuma'},
      {'title': 'Standar Seduh Otentik', 'sub': '100% Biji Gayo & Higienis'},
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Tentang Seuma.Koffie + Stats + CTA
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('TENTANG SEUMA.KOFFIE'),
              const SizedBox(height: 14),
              Text(
                'Lahir dari kecintaan mendalam terhadap kopi Aceh otentik, Seuma.Koffie menghadirkan cita rasa Sanger terbaik dari biji pilihan Gayo langsung ke tanganmu di Lhokseumawe.',
                style: TextStyle(color: AppColors.cream.withValues(alpha: 0.85), fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 22),

              // Interactive Stats Cards (All Clickable!)
              Row(
                children: [
                  _buildInteractiveStat(
                    value: '50+',
                    label: 'Menu Pilihan',
                    tooltip: 'Klik untuk lihat semua varian menu',
                    onTap: () {
                      onClose();
                      onExploreMenu();
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildInteractiveStat(
                    value: '1.000+',
                    label: 'Pelanggan Setia',
                    tooltip: 'Komitmen rasa otentik untuk warga Aceh',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❤️ Terima kasih atas kepercayaan lebih dari 1.000 penikmat kopi di Lhokseumawe!'),
                          backgroundColor: AppColors.caramel,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildInteractiveStat(
                    value: '4',
                    label: 'Kecamatan',
                    tooltip: 'Klik untuk lihat cakupan delivery kilat',
                    onTap: () {
                      onClose();
                      onScrollToLocation();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Tombol Buka Profil Lengkap
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton.icon(
                  onPressed: () {
                    onClose();
                    onScrollToAbout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.caramel,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.info_outline_rounded, size: 16),
                  label: const Text('Buka Profil Lengkap', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 48),

        // Right Column: Navigasi Cepat (Sub-Sections Deep Navigation)
        SizedBox(
          width: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('NAVIGASI CEPAT'),
              const SizedBox(height: 14),
              ...navItems.map((item) {
                return _buildFastNavLink(
                  title: item['title']!,
                  onTap: () {
                    onClose();
                    onScrollToAbout();
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.gold.withValues(alpha: 0.9),
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildInteractiveStat({
    required String value,
    required String label,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.w900)),
                Text(label, style: TextStyle(color: AppColors.cream.withValues(alpha: 0.7), fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFastNavLink({
    required String title,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.caramel),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
