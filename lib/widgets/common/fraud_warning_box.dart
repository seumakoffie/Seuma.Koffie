// lib/widgets/common/fraud_warning_box.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FraudWarningBox extends StatelessWidget {
  final bool compact;

  const FraudWarningBox({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF261204),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'WASPADA PENIPUAN MENGATASNAMAKAN SEUMA',
                  style: TextStyle(
                    color: Color(0xFFFFD54F),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Pembayaran resmi hanya diproses melalui sistem QRIS / COD terverifikasi Seuma.Koffie.\n'
            '• Kurir resmi beroperasi langsung di wilayah Lhokseumawe & Sekitarnya.\n'
            '• Tim Seuma TIDAK PERNAH meminta kode OTP, PIN perbankan, atau transfer ke rekening pribadi.',
            style: TextStyle(
              color: const Color(0xFFFFF9F2),
              fontSize: compact ? 11.5 : 12,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
