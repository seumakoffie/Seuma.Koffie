// lib/widgets/navbar/mega_menu/promo_dropdown_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';

class PromoDropdownPanel extends StatelessWidget {
  final VoidCallback onScrollToPromo;
  final VoidCallback onClose;

  const PromoDropdownPanel({
    super.key,
    required this.onScrollToPromo,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('PROMO & VOUCHER AKTIF'),
              const SizedBox(height: 14),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _buildPromoCard(
                    context,
                    emoji: '🎁',
                    code: 'SEUMAFIRST',
                    desc: 'Potongan Rp 15.000\nuntuk pesanan pertama',
                    cta: 'SALIN KODE',
                  ),
                  _buildPromoCard(
                    context,
                    emoji: '⚡',
                    code: 'JUMATBERKAH',
                    desc: 'Diskon 20%\nSetiap Jumat pagi',
                    cta: 'SALIN KODE',
                  ),
                  _buildPromoCard(
                    context,
                    emoji: '🎉',
                    code: 'BUNDLING2',
                    desc: 'Beli 2 Sanger\ngratis 1 Squash',
                    cta: 'LIHAT PROMO',
                  ),
                ],
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

  Widget _buildPromoCard(
    BuildContext context, {
    required String emoji,
    required String code,
    required String desc,
    required String cta,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: code));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Kode voucher "$code" berhasil disalin!'),
              backgroundColor: AppColors.caramel,
            ),
          );
          onClose();
          onScrollToPromo();
        },
        child: Container(
          width: 190,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.caramel.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.caramel.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(code, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: AppColors.cream.withValues(alpha: 0.85), fontSize: 11, height: 1.4)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.caramel,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(cta, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
