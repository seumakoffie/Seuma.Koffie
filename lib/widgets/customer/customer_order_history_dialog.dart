// lib/widgets/customer/customer_order_history_dialog.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/supabase_service.dart';
import '../../state/auth_state.dart';
import '../../state/cart_state.dart';
import '../../theme/app_theme.dart';
class CustomerOrderHistoryDialog extends StatefulWidget {
  const CustomerOrderHistoryDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          child: const Material(
            color: Colors.transparent,
            child: CustomerOrderHistoryDialog(),
          ),
        ),
      ),
    );
  }

  @override
  State<CustomerOrderHistoryDialog> createState() => _CustomerOrderHistoryDialogState();
}

class _CustomerOrderHistoryDialogState extends State<CustomerOrderHistoryDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> _allOrders = [];
  bool _isLoading = true;
  StreamSubscription<List<OrderModel>>? _realtimeSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _realtimeSub?.cancel();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final user = AuthManager.instance.currentUser;
    final orders = await SeumaSupabaseService.instance.fetchOrdersForCustomer(
      userId: user?.id,
      phone: user?.phone,
      recipientName: user?.name,
    );
    if (!mounted) return;
    setState(() {
      _allOrders = orders;
      _isLoading = false;
    });
  }

  void _subscribeRealtime() {
    _realtimeSub = SeumaSupabaseService.instance.ordersStream.listen((liveOrders) {
      if (!mounted) return;
      final user = AuthManager.instance.currentUser;
      final filtered = liveOrders.where((o) {
        if (user?.id != null) {
          return o.userId == user!.id || o.recipientPhone == user.phone;
        }
        final phone = AuthManager.instance.currentUser?.phone ?? '';
        return o.recipientPhone == phone;
      }).toList();
      setState(() => _allOrders = filtered);
    });
  }

  List<OrderModel> get _activeOrders => _allOrders
      .where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled)
      .toList();

  List<OrderModel> get _historyOrders => _allOrders
      .where((o) => o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
            decoration: const BoxDecoration(
              color: AppColors.espresso,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pesanan Saya', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                      Text('Live monitoring & riwayat pesanan kamu', style: TextStyle(fontSize: 11, color: AppColors.cream)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _loadOrders,
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.gold, size: 20),
                      tooltip: 'Refresh',
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── TabBar ────────────────────────────────────────────
          Container(
            color: AppColors.espresso,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.gold,
              indicatorWeight: 3,
              labelColor: AppColors.gold,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delivery_dining_rounded, size: 15),
                      const SizedBox(width: 6),
                      Text('Aktif (${_activeOrders.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_rounded, size: 15),
                      const SizedBox(width: 6),
                      Text('Riwayat (${_historyOrders.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── TabBarView ────────────────────────────────────────
          Flexible(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.caramel),
                          SizedBox(height: 14),
                          Text('Memuat pesananmu...', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActiveOrdersTab(),
                      _buildHistoryTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrdersTab() {
    if (_activeOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.coffee_maker_rounded,
        title: 'Tidak Ada Pesanan Aktif',
        subtitle: 'Pesan kopi favoritmu sekarang!\nPesanan akan muncul di sini secara realtime.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeOrders.length,
      itemBuilder: (ctx, i) => _buildActiveOrderCard(_activeOrders[i]),
    );
  }

  Widget _buildActiveOrderCard(OrderModel order) {
    final steps = ['pending', 'brewing', 'ready_for_delivery', 'on_delivery', 'delivered'];
    final currentStep = steps.indexOf(order.status.dbValue).clamp(0, 4);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.caramel.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header kartu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.espresso,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.orderNumber,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.gold),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(4)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: Colors.white, size: 10),
                      Text('LIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(order.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.cream),
                ),
              ],
            ),
          ),

          // Status Step Timeline
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepTimeline(currentStep),
                const SizedBox(height: 14),

                // Info pesanan
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.caramel),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (order.mapsUrl != null) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () {},
                    child: const Row(
                      children: [
                        Icon(Icons.map_rounded, size: 14, color: Colors.blue),
                        SizedBox(width: 4),
                        Text('Buka Google Maps →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.blue)),
                      ],
                    ),
                  ),
                ],

                const Divider(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.items.length} item • ${order.paymentMethod.displayName}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        Text(
                          formatRupiah(order.totalAmount.toInt()),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.caramel),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(order.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _statusColor(order.status).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${order.status.badgeEmoji} ${order.status.displayName}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _statusColor(order.status)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTimeline(int currentStep) {
    final steps = [
      ('Konfirmasi', Icons.pending_actions_rounded),
      ('Diseduh', Icons.coffee_maker_rounded),
      ('Siap Antar', Icons.inventory_2_rounded),
      ('Di Jalan', Icons.delivery_dining_rounded),
      ('Selesai', Icons.check_circle_rounded),
    ];

    return Row(
      children: steps.asMap().entries.map((entry) {
        final idx = entry.key;
        final step = entry.value;
        final isDone = idx < currentStep;
        final isCurrent = idx == currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppColors.caramel
                            : isCurrent
                                ? AppColors.espresso
                                : Colors.grey.shade200,
                        border: isCurrent ? Border.all(color: AppColors.gold, width: 2.5) : null,
                      ),
                      child: Icon(
                        step.$2,
                        size: 15,
                        color: (isDone || isCurrent) ? Colors.white : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.$1,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                        color: isCurrent ? AppColors.espresso : AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (idx < steps.length - 1)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 2,
                    color: isDone ? AppColors.caramel : Colors.grey.shade200,
                    margin: const EdgeInsets.only(bottom: 20),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHistoryTab() {
    if (_historyOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: 'Belum Ada Riwayat Pesanan',
        subtitle: 'Pesanan yang sudah selesai atau dibatalkan\nakan tampil di sini.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historyOrders.length,
      itemBuilder: (ctx, i) => _buildHistoryCard(_historyOrders[i]),
    );
  }

  Widget _buildHistoryCard(OrderModel order) {
    final isDelivered = order.status == OrderStatus.delivered;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDelivered ? Colors.green.shade50 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDelivered ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isDelivered ? Colors.green.shade700 : Colors.grey.shade500,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(order.orderNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.espresso)),
                    const Spacer(),
                    Text(
                      _formatDate(order.createdAt),
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.items.length} item • ${formatRupiah(order.totalAmount.toInt())}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textDark, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDelivered ? Colors.green.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '${order.status.badgeEmoji} ${order.status.displayName}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDelivered ? Colors.green.shade800 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isDelivered)
                      TextButton.icon(
                        onPressed: () => _reorder(order),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.replay_rounded, size: 13, color: AppColors.caramel),
                        label: const Text('Pesan Lagi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.caramel)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _reorder(OrderModel order) {
    final cart = CartManager.instance;
    cart.clear();
    for (final item in order.items) {
      cart.addItem(
        menuItemId: item.menuId,
        name: item.menuName,
        category: 'Kopi',
        isHot: item.variant?.toLowerCase() == 'hot',
        extraShot: item.specialNotes?.contains('Ekstra shot') ?? false,
        unitPrice: item.price.toInt(),
        quantity: item.quantity,
        iconEmoji: '☕',
      );
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${order.items.length} item dari pesanan ${order.orderNumber} ditambahkan ke keranjang!'),
        backgroundColor: AppColors.caramel,
        action: SnackBarAction(label: 'Lihat Keranjang', textColor: Colors.white, onPressed: () {}),
      ),
    );
  }
  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.caramel.withValues(alpha: 0.3)),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.5), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.brewing: return AppColors.caramel;
      case OrderStatus.readyForDelivery: return Colors.blue;
      case OrderStatus.onDelivery: return Colors.deepPurple;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.cancelled: return Colors.grey;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return _formatDate(dt);
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
