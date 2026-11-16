// lib/widgets/auth/security_trust_strip.dart
// Komponen Keamanan Terverifikasi: Blockchain Ledger & E2E Encryption
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SecurityTrustStrip extends StatelessWidget {
  final bool compact;

  const SecurityTrustStrip({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0B04), // Dark espresso roast background for crystal clear contrast
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.5),
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
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.gold,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PROTEKSI DATA KONSUMEN TINGKAT TINGGI',
                  style: TextStyle(
                    color: Color(0xFFFFD54F), // Bright, high-contrast gold
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
            'Kami mengamankan data akun dan transaksi Anda menggunakan teknologi Blockchain Ledger terdesentralisasi serta End-to-End Encryption (AES-256) untuk perlindungan privasi menyeluruh bagi seluruh penikmat kopi Seuma.',
            style: TextStyle(
              color: const Color(0xFFFFF9F2), // High-contrast crisp warm white, highly legible
              fontSize: compact ? 12 : 12.5,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMicroBadge('🔗 BLOCKCHAIN VERIFIED'),
              _buildMicroBadge('🔐 E2E ENCRYPTED (AES-256)'),
              _buildMicroBadge('🛡️ 100% DATA PRIVACY'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMicroBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1508), // Rich contrast pill background
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFFFE082), // Clear bright amber text
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
