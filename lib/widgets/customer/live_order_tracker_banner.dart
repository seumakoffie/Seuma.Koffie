// lib/widgets/customer/live_order_tracker_banner.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../state/admin_state.dart';

class LiveOrderTrackerBanner extends StatefulWidget {
  const LiveOrderTrackerBanner({super.key});

  @override
  State<LiveOrderTrackerBanner> createState() => _LiveOrderTrackerBannerState();
}

class _LiveOrderTrackerBannerState extends State<LiveOrderTrackerBanner> with SingleTickerProviderStateMixin {
  bool _isMinimized = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Pastikan admin listener realtime menyala
    AdminManager.instance.startRealtimeOrdersListener();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showDetailModal(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.espresso,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.delivery_dining, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pelacak Pesanan Realtime',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.espresso),
                              ),
                              Text(
                                '${order.orderNumber} • Live Supabase WebSocket',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF2E7D32), fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Progress Step Visualizer
                  _buildDetailedSteps(order.status),

                  const SizedBox(height: 20),

                  // Info Pengantaran
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.creamLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.caramel.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Color(0xFFC62828)),
                            SizedBox(width: 6),
                            Text('Tujuan Pengantaran Lhokseumawe:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.espresso)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(order.deliveryAddress, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                        if (order.deliveryNotes != null) ...[
                          const SizedBox(height: 3),
                          Text('Patokan: ${order.deliveryNotes}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
                        ],
                      ],
                    ),
                  ),

                  if (order.status == OrderStatus.delivered) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF81C784)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified, color: Color(0xFF2E7D32), size: 18),
                              SizedBox(width: 8),
                              Text('PESANAN SUDAH SAMPAI DI LOKASI', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Diterima oleh: ${order.recipientName}\nSegel Hash: ${order.deliveryVerificationHash ?? "Tervalidasi di Blockchain"}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.espresso,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Tutup Pelacak', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailedSteps(OrderStatus currentStatus) {
    final steps = [
      {'status': OrderStatus.pending, 'label': 'Diterima', 'icon': Icons.receipt_long},
      {'status': OrderStatus.brewing, 'label': 'Diseduh Barista', 'icon': Icons.coffee},
      {'status': OrderStatus.readyForDelivery, 'label': 'Siap Antar', 'icon': Icons.inventory_2_outlined},
      {'status': OrderStatus.onDelivery, 'label': 'Diantar Kurir', 'icon': Icons.delivery_dining},
      {'status': OrderStatus.delivered, 'label': 'Sampai di Lokasi', 'icon': Icons.check_circle},
    ];

    final currentIndex = _getStatusIndex(currentStatus);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return Expanded(
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCompleted ? (isCurrent ? AppColors.caramel : const Color(0xFF2E7D32)) : Colors.grey.shade200,
                  shape: BoxShape.circle,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.caramel.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  step['icon'] as IconData,
                  size: 18,
                  color: isCompleted ? Colors.white : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                step['label'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: isCurrent ? FontWeight.w900 : (isCompleted ? FontWeight.w700 : FontWeight.w500),
                  color: isCurrent ? AppColors.caramel : (isCompleted ? const Color(0xFF2E7D32) : Colors.grey.shade500),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  int _getStatusIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.brewing:
        return 1;
      case OrderStatus.readyForDelivery:
        return 2;
      case OrderStatus.onDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = AdminManager.instance;

    return ListenableBuilder(
      listenable: admin,
      builder: (context, _) {
        final orders = admin.orders;
        if (orders.isEmpty) return const SizedBox.shrink();

        // Cari pesanan aktif terbaru
        final activeOrder = orders.firstWhere(
          (o) => o.status != OrderStatus.cancelled,
          orElse: () => orders.first,
        );

        if (_isMinimized) {
          return Positioned(
            bottom: 24,
            right: 24,
            child: GestureDetector(
              onTap: () => setState(() => _isMinimized = false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.espresso,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                  border: Border.all(color: AppColors.gold, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.5 + (_pulseController.value * 0.5)),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '🛵 ${activeOrder.status.displayName}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: GestureDetector(
                onTap: () => _showDetailModal(context, activeOrder),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A0A04).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Status Icon Pulse
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.caramel.withValues(alpha: 0.2 + (_pulseController.value * 0.2)),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
                            ),
                            child: Icon(
                              _getStatusIcon(activeOrder.status),
                              color: const Color(0xFFFFD54F),
                              size: 20,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),

                      // Order Info & Realtime Live Status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  activeOrder.orderNumber,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFFFD54F)),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt, color: Colors.white, size: 10),
                                      Text(
                                        'REALTIME SYNC',
                                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Status: ${activeOrder.status.displayName}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            Text(
                              activeOrder.deliveryAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.75)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Action Button & Minimize
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Lacak',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.remove, color: AppColors.cream, size: 18),
                            onPressed: () => setState(() => _isMinimized = true),
                            tooltip: 'Kecilkan',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_top_rounded;
      case OrderStatus.brewing:
        return Icons.coffee_rounded;
      case OrderStatus.readyForDelivery:
        return Icons.inventory_2_rounded;
      case OrderStatus.onDelivery:
        return Icons.delivery_dining_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}
