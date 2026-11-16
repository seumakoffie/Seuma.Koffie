// lib/widgets/auth/terms_conditions_dialog.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TermsConditionsDialog extends StatelessWidget {
  const TermsConditionsDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 600),
          child: const Material(
            color: Colors.transparent,
            child: TermsConditionsDialog(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.espresso,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.gavel_rounded, color: AppColors.gold, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Syarat & Ketentuan Layanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.cream),
              ),
            ],
          ),
          const Divider(color: Colors.white12),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                _buildSection(
                  '1. Pendaftaran Akun & Verifikasi',
                  'Dengan mendaftar akun di Seuma.Koffie, Anda menyatakan bahwa data nama, email, dan nomor kontak yang dimasukkan adalah valid dan dapat dihubungi untuk koordinasi pengantaran kopi di Kota Lhokseumawe dan sekitarnya.',
                ),
                _buildSection(
                  '2. Keamanan Data & Privasi Blockchain E2EE',
                  'Seluruh informasi pribadi, alamat pengantaran, dan riwayat pesanan diamankan dengan enkripsi End-to-End (AES-256) serta dienkode ke dalam ledger transaksi terdesentralisasi berbasis Blockchain untuk mencegah pemalsuan dan penyalahgunaan data.',
                ),
                _buildSection(
                  '3. Pengantaran Kilat 15–20 Menit',
                  'Layanan siap antar kilat 15–20 menit berlaku untuk wilayah kecamatan Banda Sakti, Muara Dua, Muara Satu, dan Blang Mangat, dengan jaminan seduhan tetap hangat/dingin sesuai pesanan dalam kemasan higienis.',
                ),
                _buildSection(
                  '4. Pembayaran & Anti-Penipuan',
                  'Transaksi pembayaran hanya sah jika dilakukan melalui QRIS resmi berlabel Seuma.Koffie atau pembayaran tunai (COD) langsung kepada kurir mitra kami saat pesanan tiba.',
                ),
                _buildSection(
                  '5. Hak Pelanggan & Garansi Rasa',
                  'Jika terdapat kendala pada pesanan Anda (tumpah, pesanan tidak sesuai, atau kendala kualitas), hubungi Customer Service kami via WhatsApp untuk mendapatkan garansi seduh ulang atau pengembalian saldo.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.caramel,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Saya Mengerti & Setuju', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFD54F),
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFFFFF9F2),
              fontSize: 12.5,
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
