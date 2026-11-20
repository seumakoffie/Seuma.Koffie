// lib/widgets/admin/views/admin_orders_management_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/order_model.dart';
import '../../../theme/app_theme.dart';
import '../../../state/admin_state.dart';
import '../components/delivery_verification_modal.dart';

class AdminOrdersManagementTab extends StatelessWidget {
  const AdminOrdersManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
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
          color: order.status == OrderStatus.onDelivery ? const Color(0xFFFFA000) : Colors.grey.shade200,
          width: order.status == OrderStatus.onDelivery ? 1.5 : 1,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: order.paymentStatus == 'paid' ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${order.paymentMethod.displayName} • ${order.paymentStatus == 'paid' ? 'LUNAS' : 'BELUM DIBAYAR'}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: order.paymentStatus == 'paid' ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBgColor(order.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${order.status.badgeEmoji} ${order.status.displayName}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _statusTextColor(order.status),
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
                    if (order.deliveryNotes != null) ...[
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
                    const SizedBox(height: 8),

                    // Tombol Titik GPS Google Maps & Tag COD
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            final lat = order.deliveryLat ?? 5.1801;
                            final lng = order.deliveryLng ?? 97.1407;
                            final mapsLink = order.mapsUrl ?? 'https://www.google.com/maps?q=$lat,$lng';
                            Clipboard.setData(ClipboardData(text: mapsLink));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('📍 Koordinat Google Maps disalin: $mapsLink'),
                                backgroundColor: Colors.green.shade800,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                          icon: const Icon(Icons.map_rounded, size: 14, color: Colors.blue),
                          label: const Text('🗺️ Titik GPS Maps', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        if (order.paymentMethod == PaymentMethod.cod)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.amber.shade400),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.payments_rounded, size: 12, color: Color(0xFFE65100)),
                                const SizedBox(width: 4),
                                Text(
                                  '💵 Tagih COD: Rp ${order.totalAmount.toInt()}',
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFE65100)),
                                ),
                              ],
                            ),
                          ),
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

          const SizedBox(height: 14),

          // Action Progression Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (order.status == OrderStatus.pending) ...[
                ElevatedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.brewing),
                  icon: const Icon(Icons.coffee, size: 16),
                  label: const Text('Mulai Seduh (Barista)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.espresso,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ] else if (order.status == OrderStatus.brewing) ...[
                ElevatedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.readyForDelivery),
                  icon: const Icon(Icons.inventory_2_outlined, size: 16),
                  label: const Text('Kemas & Siap Antar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF6C00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ] else if (order.status == OrderStatus.readyForDelivery) ...[
                ElevatedButton.icon(
                  onPressed: () => admin.updateOrderStatus(order.id, OrderStatus.onDelivery),
                  icon: const Icon(Icons.delivery_dining, size: 18),
                  label: const Text('Kirim via Kurir Seuma'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0277BD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ] else if (order.status == OrderStatus.onDelivery) ...[
                // TOMBOL UTAMA: VERIFIKASI PENGANTARAN LOKASI
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
                Row(
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
              ],
            ],
          ),
        ],
      ),
    );
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
