// lib/widgets/pro/footer_v3.dart
// Corporate Multi-Column Footer for Seuma.Koffie v3.0
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'scroll_reveal.dart';

class FooterV3 extends StatefulWidget {
  const FooterV3({super.key});

  @override
  State<FooterV3> createState() => _FooterV3State();
}

class _FooterV3State extends State<FooterV3> {
  final _emailController = TextEditingController();
  bool _subscribed = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDesktop = sw > 900;

    return Column(
      children: [
        // Newsletter Strip
        ScrollReveal(
          effect: RevealEffect.fadeUp,
          child: _buildNewsletterStrip(isDesktop),
        ),

        // Main Footer
        Container(
          color: const Color(0xFF0F0501),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : 20,
            vertical: 60,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isDesktop
                  ? _buildDesktopFooter()
                  : _buildMobileFooter(),
            ),
          ),
        ),

        // Bottom Bar
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildNewsletterStrip(bool isDesktop) {
    return Container(
      color: AppColors.caramel,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 20,
        vertical: 32,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🎁 Dapatkan Promo Eksklusif!',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Daftar dan dapatkan voucher SEUMAFIRST senilai Rp 15.000 untuk pesanan pertamamu.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    _buildEmailInput(width: 380),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🎁 Dapatkan Promo Eksklusif!',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text('Daftar & dapatkan voucher Rp 15.000',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5)),
                    const SizedBox(height: 16),
                    _buildEmailInput(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildEmailInput({double? width}) {
    if (_subscribed) {
      return Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
            SizedBox(width: 8),
            Text('Berhasil! Kode dikirim ke email Anda.', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      );
    }
    return SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextField(
              controller: _emailController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Masukkan email kamu...',
                hintStyle: const TextStyle(color: Colors.black45, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => setState(() => _subscribed = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.espresso,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Daftar', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopFooter() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Col 1: Brand
            Expanded(flex: 3, child: ScrollReveal(effect: RevealEffect.fadeUp, child: _buildBrandCol())),
            const SizedBox(width: 32),
            // Col 2: Menu Unggulan
            Expanded(flex: 2, child: ScrollReveal(effect: RevealEffect.fadeUp, delay: const Duration(milliseconds: 100), child: _buildMenuCol())),
            const SizedBox(width: 32),
            // Col 3: Perusahaan
            Expanded(flex: 2, child: ScrollReveal(effect: RevealEffect.fadeUp, delay: const Duration(milliseconds: 200), child: _buildCompanyCol())),
            const SizedBox(width: 32),
            // Col 4: Lokasi & Jam
            Expanded(flex: 2, child: ScrollReveal(effect: RevealEffect.fadeUp, delay: const Duration(milliseconds: 300), child: _buildLocationCol())),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandCol(),
        const SizedBox(height: 36),
        _buildMenuCol(),
        const SizedBox(height: 36),
        _buildCompanyCol(),
        const SizedBox(height: 36),
        _buildLocationCol(),
      ],
    );
  }

  Widget _buildBrandCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.3),
            children: [
              TextSpan(text: 'Seuma.', style: TextStyle(color: AppColors.cream)),
              TextSpan(text: 'Koffie', style: TextStyle(color: AppColors.gold)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Dari biji terbaik, untuk cangkir terbaikmu. Menyajikan kopi Sanger otentik Aceh dengan cinta untuk penikmat kopi Lhokseumawe.',
          style: TextStyle(color: AppColors.cream.withValues(alpha: 0.6), fontSize: 12.5, height: 1.6),
        ),
        const SizedBox(height: 20),
        // Social Links
        Row(
          children: [
            _buildSocialIcon('📱', '@seuma.koffie'),
            const SizedBox(width: 10),
            _buildSocialBtn(Icons.chat_rounded, const Color(0xFF25D366), 'WhatsApp'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: AppColors.cream.withValues(alpha: 0.7), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSocialBtn(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildMenuCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerColTitle('MENU UNGGULAN'),
        const SizedBox(height: 16),
        ...[
          'Hot Sanger Espresso',
          'Kopi Susu Aren',
          'Kopi Americano',
          'Matcha Latte',
          'Squash Orange',
          'Kopi Saku 200ml',
        ].map((item) => _footerLink(item)),
      ],
    );
  }

  Widget _buildCompanyCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerColTitle('JAMINAN & KREDIBILITAS'),
        const SizedBox(height: 16),
        ...[
          '🛡️ 100% Biji Arabika Gayo Asli',
          '☕ Resep Sanger Otentik Aceh',
          '⚡ Garansi Hangat 15–20 Menit',
          '🧼 Higienis & Food-Grade Standar',
          '📜 Sertifikasi Halal Resmi',
          '💬 Layanan CS WhatsApp Cepat',
        ].map((item) => _footerTrustItem(item)),
      ],
    );
  }

  Widget _footerTrustItem(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.cream.withValues(alpha: 0.8),
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLocationCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _footerColTitle('INFO LOKASI'),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.location_on_rounded, size: 14, color: AppColors.caramel),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Lhokseumawe & Sekitarnya, Aceh Utara',
                style: TextStyle(color: AppColors.cream.withValues(alpha: 0.7), fontSize: 12.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.access_time_rounded, size: 14, color: AppColors.caramel),
            const SizedBox(width: 6),
            Text(
              'Buka Setiap Hari 07.00 – 22.00',
              style: TextStyle(color: AppColors.cream.withValues(alpha: 0.7), fontSize: 12.5),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.delivery_dining_rounded, size: 14, color: AppColors.caramel),
            const SizedBox(width: 6),
            Text(
              'Antar Cepat 15–20 Menit',
              style: TextStyle(color: AppColors.cream.withValues(alpha: 0.7), fontSize: 12.5),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _footerColTitle('PEMBAYARAN DITERIMA'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: ['QRIS', 'GoPay', 'OVO', 'BCA', 'COD'].map((p) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Text(p, style: TextStyle(color: AppColors.cream.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w700)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _footerColTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.gold.withValues(alpha: 0.9),
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.3,
      ),
    );
  }

  Widget _footerLink(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            Icon(Icons.arrow_forward_ios_rounded, size: 9, color: AppColors.caramel.withValues(alpha: 0.6)),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.65),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: const Color(0xFF080200),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 720;
              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Copyright & Legal
                    Row(
                      children: [
                        Text(
                          '© 2026 Seuma • Autentisitas Seduhan Aceh',
                          style: TextStyle(color: AppColors.cream.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 16),
                        _buildLegalLink('Kebijakan Privasi'),
                        const SizedBox(width: 10),
                        _buildLegalLink('Syarat & Ketentuan'),
                      ],
                    ),
                    // Right: Trust Badges
                    Row(
                      children: [
                        _buildTrustBadge('HALAL ID'),
                        const SizedBox(width: 8),
                        _buildTrustBadge('100% GAYO ORIGIN'),
                        const SizedBox(width: 8),
                        _buildTrustBadge('BI QRIS'),
                      ],
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTrustBadge('HALAL ID'),
                      const SizedBox(width: 8),
                      _buildTrustBadge('100% GAYO ORIGIN'),
                      const SizedBox(width: 8),
                      _buildTrustBadge('BI QRIS'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '© 2026 Seuma • Autentisitas Seduhan Aceh',
                    style: TextStyle(color: AppColors.cream.withValues(alpha: 0.5), fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegalLink('Kebijakan Privasi'),
                      const SizedBox(width: 12),
                      _buildLegalLink('Syarat & Ketentuan'),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLegalLink(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.cream.withValues(alpha: 0.4),
        fontSize: 11,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.cream.withValues(alpha: 0.2),
      ),
    );
  }
}
