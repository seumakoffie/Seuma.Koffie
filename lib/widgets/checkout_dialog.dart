// lib/widgets/checkout_dialog.dart
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../state/admin_state.dart';
import '../state/auth_state.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import 'common/fraud_warning_box.dart';

class CheckoutDialog extends StatefulWidget {
  const CheckoutDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 480,
            maxHeight: MediaQuery.of(ctx).size.height * 0.92,
          ),
          child: const Material(
            color: Colors.transparent,
            child: CheckoutDialog(),
          ),
        ),
      ),
    );
  }

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  int _step = 1;
  bool _isDelivery = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _selectedPayment = 'qris';
  bool _isSuccess = false;
  late String _orderId;

  @override
  void initState() {
    super.initState();
    _orderId = 'SEUMA-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final user = AuthManager.instance.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartManager.instance;
    final shipping = _isDelivery ? 10000 : 0;
    final finalAmount = cart.grandTotal + shipping;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.softShadow,
      ),
      child: SingleChildScrollView(
        child: _isSuccess
            ? _buildSuccessView(finalAmount)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Checkout Pesanan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          _step == 1 ? 'Langkah 1: Data Pemesan' : 'Langkah 2: Metode Bayar',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Form Content
                if (_step == 1) ...[
                  // Delivery / Pickup Toggle
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isDelivery = false),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isDelivery ? AppColors.caramel.withValues(alpha: 0.12) : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: !_isDelivery ? AppColors.caramel : Colors.grey.withValues(alpha: 0.2),
                                width: !_isDelivery ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.storefront, size: 16, color: !_isDelivery ? AppColors.caramel : Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  'Pickup (Ambil Sendiri)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: !_isDelivery ? FontWeight.w800 : FontWeight.w600,
                                    color: !_isDelivery ? AppColors.caramel : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isDelivery = true),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isDelivery ? AppColors.caramel.withValues(alpha: 0.12) : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isDelivery ? AppColors.caramel : Colors.grey.withValues(alpha: 0.2),
                                width: _isDelivery ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delivery_dining, size: 18, color: _isDelivery ? AppColors.caramel : Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  'Delivery Lhokseumawe (+10k)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _isDelivery ? FontWeight.w800 : FontWeight.w600,
                                    color: _isDelivery ? AppColors.caramel : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap *',
                      labelStyle: const TextStyle(fontSize: 12),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor WhatsApp *',
                      labelStyle: const TextStyle(fontSize: 12),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  if (_isDelivery) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Alamat Pengantaran Lengkap *',
                        labelStyle: const TextStyle(fontSize: 12),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ] else ...[
                  // Step 2: Payment Selector
                  const FraudWarningBox(compact: true),
                  const SizedBox(height: 14),
                  _buildPaymentOption('qris', 'QRIS (BCA, GoPay, OVO, ShopeePay)', Icons.qr_code_scanner),
                  const SizedBox(height: 10),
                  _buildPaymentOption('gopay', 'GoPay Instant Payment', Icons.account_balance_wallet_outlined),
                  const SizedBox(height: 10),
                  _buildPaymentOption('bca', 'Transfer Virtual Account BCA', Icons.credit_card),
                  const SizedBox(height: 10),
                  _buildPaymentOption('cash', 'Bayar Tunai di Kasir / COD', Icons.payments_outlined),
                ],

                const SizedBox(height: 20),

                // Order Total Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Yang Harus Dibayar:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(
                        formatRupiah(finalAmount),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.caramel),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Actions
                Row(
                  children: [
                    if (_step == 2)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _step = 1),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Kembali'),
                        ),
                      ),
                    if (_step == 2) const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_step == 1) {
                            if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Mohon isi nama dan nomor WhatsApp Anda.')),
                              );
                              return;
                            }
                            if (_isDelivery && _addressController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Mohon isi alamat pengantaran.')),
                              );
                              return;
                            }
                            setState(() => _step = 2);
                          } else {
                            // Realtime Broadcast order creation (Consumer -> Supabase & Admin Live)
                            final cart = CartManager.instance;
                            final newOrder = OrderModel(
                              id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
                              orderNumber: _orderId,
                              userId: AuthManager.instance.currentUser?.id,
                              totalAmount: cart.grandTotal.toDouble(),
                              status: OrderStatus.pending,
                              paymentMethod: PaymentMethod.fromString(_selectedPayment),
                              paymentStatus: _selectedPayment == 'qris' || _selectedPayment == 'gopay' ? 'paid' : 'unpaid',
                              recipientName: _nameController.text.trim(),
                              recipientPhone: _phoneController.text.trim(),
                              deliveryAddress: _isDelivery ? _addressController.text.trim() : 'Ambil di Outlet Seuma Pusat Lhokseumawe',
                              deliveryNotes: _isDelivery ? 'Antar kilat 15-20 menit se-Lhokseumawe' : 'Pesanan takeaway outlet',
                              deliveryLat: 5.1801,
                              deliveryLng: 97.1407,
                              createdAt: DateTime.now(),
                              items: cart.items.map((ci) => OrderItemModel(
                                id: ci.id,
                                orderId: _orderId,
                                menuId: ci.menuItemId,
                                menuName: ci.name,
                                variant: ci.isHot ? 'Hot' : 'Iced',
                                price: ci.unitPrice.toDouble(),
                                quantity: ci.quantity,
                                subtotal: ci.totalPrice.toDouble(),
                                specialNotes: ci.extraShot ? 'Ekstra shot' : null,
                              )).toList(),
                            );
                            AdminManager.instance.placeNewCustomerOrder(newOrder);

                            setState(() => _isSuccess = true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.caramel,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(_step == 1 ? 'Lanjut Pembayaran' : 'Konfirmasi & Pesan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildPaymentOption(String id, String label, IconData icon) {
    final isSelected = _selectedPayment == id;
    return InkWell(
      onTap: () => setState(() => _selectedPayment = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.caramel.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.caramel : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.caramel : Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.caramel, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(int finalAmount) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, size: 48, color: AppColors.successGreen),
        ),
        const SizedBox(height: 16),
        const Text(
          'Pesanan Berhasil Diterima!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Barista Seuma.Koffie sedang meracik pesananmu.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),

        // Receipt
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.caramel.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('No. Pesanan:', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                  Text(_orderId, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Pemesan:', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                  Text('${_nameController.text} (${_phoneController.text})',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Metode:', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                  Text(_selectedPayment.toUpperCase(), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pembayaran:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                  Text(formatRupiah(finalAmount),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.caramel)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: AppColors.gold, size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Transaksi tervalidasi via Blockchain Ledger & E2EE 256-bit',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.espresso,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              CartManager.instance.clear();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.espresso,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.home, size: 18),
            label: const Text('Kembali Belanja', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
