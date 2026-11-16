// lib/widgets/navbar/mega_menu/location_dropdown_panel.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class LocationDropdownPanel extends StatelessWidget {
  final VoidCallback onScrollToLocation;
  final VoidCallback onClose;

  const LocationDropdownPanel({
    super.key,
    required this.onScrollToLocation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final areas = [
      {'name': 'Banda Sakti', 'time': '10–15 mnt', 'emoji': '🏘️'},
      {'name': 'Muara Dua', 'time': '12–18 mnt', 'emoji': '🏘️'},
      {'name': 'Muara Satu', 'time': '15–20 mnt', 'emoji': '🏘️'},
      {'name': 'Blang Mangat', 'time': '18–22 mnt', 'emoji': '🏘️'},
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('AREA PENGANTARAN KILAT LHOKSEUMAWE'),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: areas.map((a) => MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      onClose();
                      onScrollToLocation();
                    },
                    child: Container(
                      width: 160,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.caramel.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a['emoji']!, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 6),
                          Text(a['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                          Text(a['time']!, style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('HUBUNGI KAMI'),
              const SizedBox(height: 14),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    onClose();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menghubungkan ke WhatsApp CS Seuma.Koffie...')),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_rounded, size: 15, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'WhatsApp Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Buka Setiap Hari\n07.00 – 22.00 WIB\nSiap Antar 15–20 Mnt',
                style: TextStyle(color: AppColors.cream.withValues(alpha: 0.8), fontSize: 12.5, height: 1.5),
              ),
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
}
