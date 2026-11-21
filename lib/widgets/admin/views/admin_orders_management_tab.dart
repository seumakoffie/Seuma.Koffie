// lib/widgets/admin/views/admin_orders_management_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/order_model.dart';
import '../../../theme/app_theme.dart';
import '../../../state/admin_state.dart';
import '../components/delivery_verification_modal.dart';
import '../components/admin_delivery_mini_map.dart';
import '../components/admin_map_full_view_modal.dart';

class AdminOrdersManagementTab extends StatelessWidget {
  const AdminOrdersManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminManager.instance,
      builder: (context, _) {
        final admin = AdminManager.instance;
        final orders = admin.filteredOrders;
        final currentFilter = admin.orderFilter;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'Semua Pesanan (${admin.orders.length})',
                    isSelected: currentFilter == null,
                    onTap: () => admin.setOrderFilter(null),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '🟡 Menunggu (${admin.orders.where((o) => o.status == OrderStatus.pending).length})',
                    isSelected: currentFilter == OrderStatus.pending,
                    onTap: () => admin.setOrderFilter(OrderStatus.pending),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '☕ Diseduh (${admin.orders.where((o) => o.status == OrderStatus.brewing).length})',
                    isSelected: currentFilter == OrderStatus.brewing,
                    onTap: () => admin.setOrderFilter(OrderStatus.brewing),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '📦 Siap Diantar (${admin.orders.where((o) => o.status == OrderStatus.readyForDelivery).length})',
                    isSelected: currentFilter == OrderStatus.readyForDelivery,
                    onTap: () => admin.setOrderFilter(OrderStatus.readyForDelivery),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '🛵 Pengantaran (${admin.orders.where((o) => o.status == OrderStatus.onDelivery).length})',
                    isSelected: currentFilter == OrderStatus.onDelivery,
                    onTap: () => admin.setOrderFilter(OrderStatus.onDelivery),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '✅ Selesai (${admin.orders.where((o) => o.status == OrderStatus.delivered).length})',
                    isSelected: currentFilter == OrderStatus.delivered,
                    onTap: () => admin.setOrderFilter(OrderStatus.delivered),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: '❌ Dibatalkan (${admin.orders.where((o) => o.status == OrderStatus.cancelled).length})',
                    isSelected: currentFilter == OrderStatus.cancelled,
                    onTap: () => admin.setOrderFilter(OrderStatus.cancelled),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Order Cards List
            Expanded(
              child: orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text(
                            'Tidak ada pesanan pada filter ini.',
                            style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _buildOrderCard(context, order);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.espresso : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.espresso : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.espresso.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final admin = AdminManager.instance;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: order.status == OrderStatus.onDelivery
              ? const Color(0xFFFFA000)
              : (order.status == OrderStatus.delivered ? const Color(0xFFA5D6A7) : Colors.grey.shade200),
          width: (order.status == OrderStatus.onDelivery || order.status == OrderStatus.delivered) ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.creamLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.caramel.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      order.orderNumber,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: AppColors.caramel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')} WIB',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                ],
              ),
              Row(
                children: [
                  // Status Pembayaran (Bisa diklik untuk ubah Lunas / Belum Lunas)
                  Tooltip(
                    message: order.paymentStatus == 'paid' ? 'Status: LUNAS' : 'Klik untuk tandai LUNAS',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        final nextStatus = order.paymentStatus == 'paid' ? 'unpaid' : 'paid';
                        _confirmPaymentStatus(context, admin, order, nextStatus);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: order.paymentStatus == 'paid' ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: order.paymentStatus == 'paid' ? const Color(0xFFA5D6A7) : const Color(0xFFFFCC80),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${order.paymentMethod.displayName} • ${order.paymentStatus == 'paid' ? 'LUNAS' : 'BELUM DIBAYAR'}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: order.paymentStatus == 'paid' ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              order.paymentStatus == 'paid' ? Icons.check_circle : Icons.edit,
                              size: 11,
                              color: order.paymentStatus == 'paid' ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Menu Dropdown Status Fleksibel
                  PopupMenuButton<OrderStatus>(
                    tooltip: 'Ubah status pesanan langsung',
                    initialValue: order.status,
                    onSelected: (newStatus) async {
                      if (newStatus == order.status) return;
                      if (newStatus == OrderStatus.delivered) {
                        DeliveryVerificationModal.show(context, order);
                        return;
                      }
                      if (newStatus == OrderStatus.cancelled) {
                        _confirmCancelOrder(context, admin, order);
                        return;
                      }
                      final ok = await admin.updateOrderStatus(order.id, newStatus);
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Status pesanan diubah ke: ${newStatus.badgeEmoji} ${newStatus.displayName}'),
                            backgroundColor: const Color(0xFF2E7D32),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => OrderStatus.values.map((st) {
                      return PopupMenuItem<OrderStatus>(
                        value: st,
                        child: Row(
                          children: [
                            Text(st.badgeEmoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Text(
                              st.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: st == order.status ? FontWeight.w800 : FontWeight.w500,
                                color: st == order.status ? AppColors.caramel : AppColors.textDark,
                              ),
                            ),
                            if (st == order.status) ...[
                              const Spacer(),
                              const Icon(Icons.check, size: 16, color: AppColors.caramel),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusBgColor(order.status),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _statusTextColor(order.status), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: _statusTextColor(order.status).withValues(alpha: 0.15), blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${order.status.badgeEmoji} ${order.status.displayName}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: _statusTextColor(order.status),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down_circle_outlined, size: 14, color: _statusTextColor(order.status)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Customer & Delivery Address Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFC62828)),
                        const SizedBox(width: 4),
                        const Text(
                          'Alamat Pengantaran (Lhokseumawe):',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.espresso),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.deliveryAddress,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    if (order.deliveryNotes != null && order.deliveryNotes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Patokan: ${order.deliveryNotes}',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      'Penerima: ${order.recipientName} (${order.recipientPhone})',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textDark),
                    ),

                    // === Mini-Map Preview (hanya jika koordinat GPS tersedia) ===
                    if (order.deliveryLat != null && order.deliveryLng != null) ...[
                      const SizedBox(height: 10),
                      AdminDeliveryMiniMap(
                        lat: order.deliveryLat!,
                        lng: order.deliveryLng!,
                        address: order.deliveryAddress,
                        onTap: () => AdminMapFullViewModal.show(context, order),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Tombol Aksi: Navigasi GPS, Chat WA, Peta, COD
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        // Tombol Rute Google Maps (buka browser langsung)
                        OutlinedButton.icon(
                          onPressed: () async {
                            final lat = order.deliveryLat ?? 5.1801;
                            final lng = order.deliveryLng ?? 97.1407;
                            final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
                            final messenger = ScaffoldMessenger.of(context);
                            final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
                            if (!opened) {
                              await Clipboard.setData(ClipboardData(text: uri.toString()));
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('📋 Link rute disalin (browser tidak terbuka): $uri'),
                                  backgroundColor: const Color(0xFF1B5E20),
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.directions_bike_rounded, size: 14, color: Color(0xFF2E7D32)),
                          label: const Text('🛵 Rute Google Maps', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1B5E20))),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8F5E9),
                            side: const BorderSide(color: Color(0xFF81C784)),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),

                        // Tombol Lihat Peta Besar (modal interaktif)
                        OutlinedButton.icon(
                          onPressed: () => AdminMapFullViewModal.show(context, order),
                          icon: const Icon(Icons.map_rounded, size: 13, color: Color(0xFF5C6BC0)),
                          label: const Text('🔍 Lihat Peta', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF5C6BC0))),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8EAF6),
                            side: const BorderSide(color: Color(0xFF9FA8DA)),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),

                        OutlinedButton.icon(
                          onPressed: () {
                            final phone = order.recipientPhone.replaceAll(RegExp(r'[^0-9]'), '');
                            final normalizedPhone = phone.startsWith('0') ? '62${phone.substring(1)}' : (phone.startsWith('62') ? phone : '62$phone');
                            final waLink = 'https://wa.me/$normalizedPhone?text=Halo%20${Uri.encodeComponent(order.recipientName)},%20kurir%20Seuma.Koffie%20sedang%20mengantar%20pesanan%20${order.orderNumber}';
                            Clipboard.setData(ClipboardData(text: waLink));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('💬 Tautan WhatsApp Pemesan disalin: $waLink'),
                                backgroundColor: const Color(0xFF00796B),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_rounded, size: 13, color: Color(0xFF00796B)),
                          label: const Text('💬 Chat WA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF00796B))),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0F2F1),
                            side: const BorderSide(color: Color(0xFF80CBC4)),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        if (order.paymentMethod == PaymentMethod.cod) ...[
                          if (order.paymentStatus != 'paid')
                            ElevatedButton.icon(
                              onPressed: () => _confirmPaymentStatus(context, admin, order, 'paid'),
                              icon: const Icon(Icons.payments_rounded, size: 13),
                              label: Text(
                                '💵 Terima COD: Rp ${order.totalAmount.toInt()}',
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE65100),
                                foregroundColor: Colors.white,
                                elevation: 1,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFA5D6A7)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF2E7D32)),
                                  SizedBox(width: 4),
                                  Text(
                                    '✅ LUNAS (COD Diterima)',
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF1B5E20)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Items Summary
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rincian Menu:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.espresso),
                      ),
                      const SizedBox(height: 4),
                      ...order.items.map((it) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${it.quantity}x ${it.menuName} (${it.variant ?? 'Default'})',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textDark),
                              ),
                              Text(
                                'Rp ${(it.subtotal.toInt())}',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                          Text(
                            'Rp ${order.totalAmount.toInt()}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.caramel),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Interactive Status Stepper Pipeline (Semua Tahapan Bisa Diklik Langsung)
          _buildStatusStepper(context, admin, order),

          const SizedBox(height: 14),

          // Action Progression Bar
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (order.status == OrderStatus.pending) ...[
                OutlinedButton.icon(
                  onPressed: () => _confirmCancelOrder(context, admin, order),
                  icon: const Icon(Icons.cancel_outlined, size: 14, color: Color(0xFFC62828)),
                  label: const Text('Batalkan', style: TextStyle(fontSize: 11.5, color: Color(0xFFC62828))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF9A9A)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.readyForDelivery),
                  icon: const Icon(Icons.inventory_2_outlined, size: 15, color: Color(0xFFE65100)),
                  label: const Text('📦 Siap Antar', style: TextStyle(fontSize: 11.5, color: Color(0xFFE65100), fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF3E0),
                    side: const BorderSide(color: Color(0xFFFFCC80)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.onDelivery),
                  icon: const Icon(Icons.delivery_dining, size: 16),
                  label: const Text('🛵 Langsung Diantar', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0277BD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.brewing),
                  icon: const Icon(Icons.coffee, size: 16),
                  label: const Text('☕ Mulai Seduh (Barista)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.espresso,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else if (order.status == OrderStatus.brewing) ...[
                OutlinedButton.icon(
                  onPressed: () => _confirmCancelOrder(context, admin, order),
                  icon: const Icon(Icons.cancel_outlined, size: 14, color: Color(0xFFC62828)),
                  label: const Text('Batalkan', style: TextStyle(fontSize: 11.5, color: Color(0xFFC62828))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF9A9A)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.onDelivery),
                  icon: const Icon(Icons.delivery_dining, size: 16),
                  label: const Text('🛵 Langsung Kirim (Kurir)', style: TextStyle(fontSize: 11.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0277BD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.readyForDelivery),
                  icon: const Icon(Icons.inventory_2_outlined, size: 16),
                  label: const Text('📦 Kemas & Siap Antar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF6C00),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else if (order.status == OrderStatus.readyForDelivery) ...[
                OutlinedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.brewing),
                  icon: const Icon(Icons.undo, size: 14),
                  label: const Text('☕ Balik ke Seduh', style: TextStyle(fontSize: 11.5)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.onDelivery),
                  icon: const Icon(Icons.delivery_dining, size: 18),
                  label: const Text('🛵 Kirim via Kurir Seuma'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0277BD),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else if (order.status == OrderStatus.onDelivery) ...[
                OutlinedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.readyForDelivery),
                  icon: const Icon(Icons.undo, size: 14),
                  label: const Text('Balik Siap Antar', style: TextStyle(fontSize: 11.5)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.delivered),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('✅ Tandai Selesai', style: TextStyle(fontSize: 11.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => DeliveryVerificationModal.show(context, order),
                  icon: const Icon(Icons.verified_user, size: 18),
                  label: const Text('🛵 Verifikasi Sampai di Lokasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ] else if (order.status == OrderStatus.delivered) ...[
                // Info Bukti & Segel Blockchain
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Terkonfirmasi Sampai: ${order.deliveredAt != null ? '${order.deliveredAt!.hour.toString().padLeft(2, '0')}:${order.deliveredAt!.minute.toString().padLeft(2, '0')} WIB' : 'OK'}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFA5D6A7)),
                      ),
                      child: const Text('⛓️ Segel Blockchain Sah', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20))),
                    ),
                  ],
                ),
                const SizedBox(width: 8),

                // Tombol Aksi Fleksibel untuk Mengubah / Mengembalikan Status Selesai
                OutlinedButton.icon(
                  onPressed: () => _confirmCancelOrder(context, admin, order),
                  icon: const Icon(Icons.cancel_outlined, size: 14, color: Color(0xFFC62828)),
                  label: const Text('Batalkan', style: TextStyle(fontSize: 11.5, color: Color(0xFFC62828))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF9A9A)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.brewing),
                  icon: const Icon(Icons.coffee, size: 14),
                  label: const Text('☕ Balik ke Seduh', style: TextStyle(fontSize: 11.5)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.onDelivery),
                  icon: const Icon(Icons.delivery_dining, size: 15, color: Color(0xFF0277BD)),
                  label: const Text('🔄 Kembalikan ke Pengantaran', style: TextStyle(fontSize: 11.5, color: Color(0xFF0277BD), fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE1F5FE),
                    side: const BorderSide(color: Color(0xFF81D4FA)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => DeliveryVerificationModal.show(context, order),
                  icon: const Icon(Icons.verified_user, size: 16),
                  label: const Text('🛵 Lihat Verifikasi', style: TextStyle(fontSize: 11.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else if (order.status == OrderStatus.cancelled) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEF9A9A)),
                  ),
                  child: const Text('❌ Pesanan Telah Dibatalkan', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFC62828))),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.pending),
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Aktifkan Lagi (Menunggu)', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Interactive Status Stepper Pipeline Widget
  Widget _buildStatusStepper(BuildContext context, AdminManager admin, OrderModel order) {
    final stages = [
      OrderStatus.pending,
      OrderStatus.brewing,
      OrderStatus.readyForDelivery,
      OrderStatus.onDelivery,
      OrderStatus.delivered,
    ];

    final currentIndex = stages.indexOf(order.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alur Status Pesanan (Klik tahapan untuk ubah cepat):',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
              ),
              Text(
                'Tahap ${currentIndex >= 0 ? currentIndex + 1 : '-'}/5',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.caramel),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: stages.asMap().entries.map((entry) {
                final idx = entry.key;
                final st = entry.value;
                final isCurrent = st == order.status;
                final isPassed = currentIndex >= 0 && idx < currentIndex;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        if (st == order.status) return;
                        if (st == OrderStatus.delivered) {
                          DeliveryVerificationModal.show(context, order);
                          return;
                        }
                        final ok = await admin.updateOrderStatus(order.id, st);
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Status pesanan diubah ke: ${st.badgeEmoji} ${st.displayName}'),
                              backgroundColor: const Color(0xFF2E7D32),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? _statusBgColor(st)
                              : (isPassed ? const Color(0xFFE8F5E9) : Colors.white),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrent
                                ? _statusTextColor(st)
                                : (isPassed ? const Color(0xFFA5D6A7) : Colors.grey.shade300),
                            width: isCurrent ? 1.6 : 1.0,
                          ),
                          boxShadow: isCurrent
                              ? [BoxShadow(color: _statusTextColor(st).withValues(alpha: 0.2), blurRadius: 4)]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(st.badgeEmoji, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              st.displayName,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isCurrent ? FontWeight.w900 : (isPassed ? FontWeight.w700 : FontWeight.w500),
                                color: isCurrent
                                    ? _statusTextColor(st)
                                    : (isPassed ? const Color(0xFF1B5E20) : AppColors.textDark),
                              ),
                            ),
                            if (isPassed) ...[
                              const SizedBox(width: 3),
                              const Icon(Icons.check, size: 11, color: Color(0xFF2E7D32)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (idx < stages.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: isPassed ? const Color(0xFF81C784) : Colors.grey.shade400,
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPaymentStatus(BuildContext context, AdminManager admin, OrderModel order, String newStatus) async {
    final isPaid = newStatus == 'paid';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(isPaid ? Icons.check_circle : Icons.warning_amber_rounded, color: isPaid ? const Color(0xFF2E7D32) : const Color(0xFFE65100)),
            const SizedBox(width: 8),
            Text(isPaid ? 'Konfirmasi Lunas' : 'Ubah ke Belum Lunas', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          isPaid
              ? 'Tandai pembayaran pesanan ${order.orderNumber} (${order.paymentMethod.displayName}) sebesar Rp ${order.totalAmount.toInt()} sebagai LUNAS?'
              : 'Kembalikan status pembayaran pesanan ${order.orderNumber} menjadi BELUM DIBAYAR?',
          style: const TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPaid ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isPaid ? 'Ya, Tandai Lunas' : 'Ya, Belum Lunas'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await admin.updatePaymentStatus(order.id, newStatus);
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPaid
                ? '✅ Pembayaran pesanan ${order.orderNumber} berhasil ditandai LUNAS!'
                : 'Status pembayaran ${order.orderNumber} diubah ke BELUM DIBAYAR.'),
            backgroundColor: isPaid ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
          ),
        );
      }
    }
  }

  Future<void> _confirmCancelOrder(BuildContext context, AdminManager admin, OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828)),
            SizedBox(width: 8),
            Text('Batalkan Pesanan?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan pesanan ${order.orderNumber} (${order.recipientName})?',
          style: const TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ya, Batalkan Pesanan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await admin.updateOrderStatus(order.id, OrderStatus.cancelled);
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan ${order.orderNumber} telah dibatalkan.'),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
      }
    }
  }

  Color _statusBgColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFFFF8E1);
      case OrderStatus.brewing:
        return const Color(0xFFEFEBE9);
      case OrderStatus.readyForDelivery:
        return const Color(0xFFFFF3E0);
      case OrderStatus.onDelivery:
        return const Color(0xFFE1F5FE);
      case OrderStatus.delivered:
        return const Color(0xFFE8F5E9);
      case OrderStatus.cancelled:
        return const Color(0xFFFFEBEE);
    }
  }

  Color _statusTextColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFF57F17);
      case OrderStatus.brewing:
        return AppColors.espresso;
      case OrderStatus.readyForDelivery:
        return const Color(0xFFE65100);
      case OrderStatus.onDelivery:
        return const Color(0xFF0277BD);
      case OrderStatus.delivered:
        return const Color(0xFF2E7D32);
      case OrderStatus.cancelled:
        return const Color(0xFFC62828);
    }
  }
}
