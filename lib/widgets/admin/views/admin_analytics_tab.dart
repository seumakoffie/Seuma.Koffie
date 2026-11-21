// lib/widgets/admin/views/admin_analytics_tab.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../state/admin_state.dart';
import '../../../models/admin_analytics_model.dart';
import '../components/analytics_chart_painter.dart';

class AdminAnalyticsTab extends StatelessWidget {
  const AdminAnalyticsTab({super.key});

  String _formatRupiah(num amount) {
    final str = amount.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminManager.instance,
      builder: (context, _) {
        final admin = AdminManager.instance;
        final summary = admin.analyticsSummary;
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth > 980;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Top KPI Summary Cards (4 Metrik Utama) ─────────────────
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildKpiCard(
                    context: context,
                    icon: Icons.payments_rounded,
                    title: 'Total Omset Lunas (COD)',
                    value: _formatRupiah(summary.totalRevenuePaid),
                    subtitle: '${summary.totalPaidOrdersCount} Pesanan Terkonfirmasi Lunas',
                    badge: 'AUTO-SYNC',
                    accentColor: const Color(0xFF2E7D32),
                    width: isDesktop ? (screenWidth - 56 - 36) / 4 : (screenWidth - 28 - 12) / 2,
                  ),
                  _buildKpiCard(
                    context: context,
                    icon: Icons.delivery_dining_rounded,
                    title: 'COD Pending / Berjalan',
                    value: _formatRupiah(summary.totalRevenuePending),
                    subtitle: 'Tagihan Belum Diterima Kurir',
                    badge: 'MENUNGGU',
                    accentColor: const Color(0xFFE65100),
                    width: isDesktop ? (screenWidth - 56 - 36) / 4 : (screenWidth - 28 - 12) / 2,
                  ),
                  _buildKpiCard(
                    context: context,
                    icon: Icons.people_alt_rounded,
                    title: 'Total Konsumen Terdaftar',
                    value: '${summary.totalConsumersCount} Member',
                    subtitle: '+${summary.newConsumersLast7Days} Akun Baru (7 Hari)',
                    badge: 'TRAFIK NAIK',
                    accentColor: const Color(0xFF00796B),
                    width: isDesktop ? (screenWidth - 56 - 36) / 4 : (screenWidth - 28 - 12) / 2,
                  ),
                  _buildKpiCard(
                    context: context,
                    icon: Icons.receipt_long_rounded,
                    title: 'Rata-Rata Nilai Belanja (AOV)',
                    value: _formatRupiah(summary.averageOrderValue),
                    subtitle: 'Dari ${summary.totalPaidOrdersCount} Transaksi Lunas',
                    badge: 'PER TRANSAKSI',
                    accentColor: const Color(0xFF6A1B9A),
                    width: isDesktop ? (screenWidth - 56 - 36) / 4 : (screenWidth - 28 - 12) / 2,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── 2. Grid Dua Grafik Analitik (Trafik Akun vs Menu Terlaris) ──
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildUserTrafficCard(summary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: _buildTopSellingCard(summary),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildUserTrafficCard(summary),
                    const SizedBox(height: 16),
                    _buildTopSellingCard(summary),
                  ],
                ),

              const SizedBox(height: 20),

              // ── 3. Analitik Menu Kurang Laku (Slow Moving) ─────────────────
              _buildSlowMovingCard(summary),

              const SizedBox(height: 20),

              // ── 4. Log Arus Kas & Riwayat Pembayaran COD Terbaru ────────────
              _buildRecentPaidOrdersCard(admin),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required String badge,
    required Color accentColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: accentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accentColor),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTrafficCard(AdminAnalyticsSummary summary) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
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
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: AppColors.espresso, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Grafik Trafik Pendaftaran Akun Konsumen',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.espresso),
                ),
              ),
              Text(
                '7 Hari Terakhir',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.caramel),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Tren harian konsumen baru yang membuat akun di ekosistem Seuma.Koffie.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),

          // Komponen Visual Bar Chart
          RegistrationTrafficBarChart(stats: summary.dailyRegistrations, height: 160),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetric('Total Konsumen', '${summary.totalConsumersCount} User', Icons.group),
              _buildMiniMetric('Akun Baru Minggu Ini', '+${summary.newConsumersLast7Days} User', Icons.trending_up),
              _buildMiniMetric('Total Pesanan Selesai', '${summary.totalDeliveredOrdersCount} Pesanan', Icons.done_all),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingCard(AdminAnalyticsSummary summary) {
    final topItems = summary.topSellingItems;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
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
          const Row(
            children: [
              Icon(Icons.star_rounded, color: Color(0xFFFFA000), size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Peringkat Minuman Terlaris (Best Seller ⭐)',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.espresso),
                ),
              ),
              Text(
                'Top 5 Menu',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Menu kopi dan minuman dengan frekuensi pemesanan tertinggi.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),

          if (topItems.isEmpty)
            Container(
              height: 160,
              alignment: Alignment.center,
              child: const Text('Belum ada data penjualan minuman.', style: TextStyle(color: AppColors.textMuted)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = topItems[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? const Color(0xFFFFD54F)
                                : (index == 1 ? const Color(0xFFCFD8DC) : const Color(0xFFFFCCBC)),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.espresso),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${item.totalQuantity} Porsi',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.espresso),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatRupiah(item.totalRevenue),
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (item.percentageOfSales / 100).clamp(0.05, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        color: index == 0 ? const Color(0xFFFFA000) : AppColors.caramel,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSlowMovingCard(AdminAnalyticsSummary summary) {
    final slowItems = summary.slowMovingItems;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Menu Kurang Laku / Butuh Perhatian (Slow-Moving Items ⚠️)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFBF360C)),
                ),
              ),
              Text(
                'Saran Strategi Promo',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFE65100)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Daftar menu kopi/minuman dengan pesanan 0 atau paling sedikit. Disarankan untuk dijadikan Paket Bundling atau Promo Diskon agar bahan baku segar tidak tertimbun.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF5D4037)),
          ),
          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: slowItems.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFD54F)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.coffee, size: 14, color: Color(0xFFE65100)),
                    const SizedBox(width: 6),
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.espresso),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${item.totalQuantity} Terjual',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFC62828)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPaidOrdersCard(AdminManager admin) {
    final paidOrders = admin.orders.where((o) => o.paymentStatus.toLowerCase() == 'paid').take(5).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
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
          const Row(
            children: [
              Icon(Icons.history_rounded, color: AppColors.espresso, size: 20),
              SizedBox(width: 8),
              Text(
                'Arus Kas: 5 Transaksi Lunas Terkini (COD & Transfer)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.espresso),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (paidOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('Belum ada pesanan dengan status Lunas.', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paidOrders.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final o = paidOrders[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o.orderNumber,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.espresso),
                            ),
                            Text(
                              'Penerima: ${o.recipientName} • Metode: ${o.paymentMethod.displayName}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatRupiah(o.totalAmount),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.caramel),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.espresso)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}
