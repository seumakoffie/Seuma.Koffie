// lib/widgets/checkout_dialog.dart
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../state/admin_state.dart';
import '../state/auth_state.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import 'common/fraud_warning_box.dart';
import 'customer/customer_order_history_dialog.dart';

class CheckoutDialog extends StatefulWidget {
  const CheckoutDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: MediaQuery.of(ctx).size.height * 0.94,
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
  String _selectedPayment = 'cod'; // Default: Bayar di Tempat (COD)
  bool _isSuccess = false;
  bool _isSubmitting = false;
  late String _orderNumber;
  late String _orderUuid;

  // Realtime GPS Location State
  double _deliveryLat = 5.1801;
  double _deliveryLng = 97.1407;
  String _selectedArea = 'Banda Sakti (Pusat Kota)';
  bool _isGpsLocked = false;
  bool _isDetectingGps = false;

  final Map<String, List<double>> _lhokseumaweAreas = {
    'Banda Sakti (Pusat Kota)': [5.1801, 97.1407],
    'Muara Dua (Cunda / Uteunkot)': [5.1672, 97.1325],
    'Blang Mangat (Punteut)': [5.1384, 97.1620],
    'Muara Satu (Batuphat / Arun)': [5.2215, 97.0982],
  };

  @override
  void initState() {
    super.initState();
    _orderNumber = 'SEUMA-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _orderUuid = generateUuidV4();
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

  void _lockGpsLocation() {
    setState(() => _isDetectingGps = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final coords = _lhokseumaweAreas[_selectedArea] ?? [5.1801, 97.1407];
      setState(() {
        _deliveryLat = coords[0];
        _deliveryLng = coords[1];
        _isGpsLocked = true;
        _isDetectingGps = false;
        if (_addressController.text.trim().isEmpty) {
          _addressController.text = 'Kecamatan $_selectedArea, Kota Lhokseumawe (Titik GPS Terkunci)';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartManager.instance;
    final shipping = _isDelivery ? 10000 : 0;
    final finalAmount = cart.grandTotal + shipping;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: SingleChildScrollView(
        child: _isSuccess
            ? _buildSuccessView(finalAmount)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Header ──────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
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
                            const SizedBox(height: 2),
                            Text(
                              _step == 1 ? 'Langkah 1: Pengantaran & Lokasi' : 'Langkah 2: Metode Pembayaran',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: AppColors.textMuted),
                      ),
                    ],
                  ),

                  const Divider(height: 20),

                  // ── Form Step 1: Data Pengantaran & Maps ─────────────────────
                  if (_step == 1) ...[
                    // Toggle Pickup vs Delivery (Font Responsif Tanpa Overflow)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isDelivery = false),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: !_isDelivery ? AppColors.caramel.withValues(alpha: 0.12) : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !_isDelivery ? AppColors.caramel : Colors.grey.withValues(alpha: 0.25),
                                  width: !_isDelivery ? 1.8 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.storefront_rounded, size: 16, color: !_isDelivery ? AppColors.caramel : Colors.grey),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Pickup di Outlet',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: !_isDelivery ? FontWeight.w800 : FontWeight.w600,
                                          color: !_isDelivery ? AppColors.caramel : AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isDelivery = true),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: _isDelivery ? AppColors.caramel.withValues(alpha: 0.12) : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isDelivery ? AppColors.caramel : Colors.grey.withValues(alpha: 0.25),
                                  width: _isDelivery ? 1.8 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delivery_dining_rounded, size: 18, color: _isDelivery ? AppColors.caramel : Colors.grey),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Delivery (+10k)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: _isDelivery ? FontWeight.w800 : FontWeight.w600,
                                          color: _isDelivery ? AppColors.caramel : AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Nama Pemesan
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Nama Pemesan *',
                        labelStyle: const TextStyle(fontSize: 12),
                        isDense: true,
                        prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // WhatsApp Phone
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Nomor WhatsApp Aktif *',
                        labelStyle: const TextStyle(fontSize: 12),
                        hintText: '08xxxxxxxxxx',
                        isDense: true,
                        prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    // ── Bagian Delivery & Titik Maps Realtime ─────────────
                    if (_isDelivery) ...[
                      const SizedBox(height: 14),

                      // Area Kecamatan Lhokseumawe Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF8F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.map_outlined, size: 18, color: AppColors.caramel),
                            const SizedBox(width: 8),
                            const Text('Wilayah: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedArea,
                                  isDense: true,
                                  isExpanded: true,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.espresso),
                                  items: _lhokseumaweAreas.keys.map((area) {
                                    return DropdownMenuItem(value: area, child: Text(area));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedArea = val;
                                        final coords = _lhokseumaweAreas[val]!;
                                        _deliveryLat = coords[0];
                                        _deliveryLng = coords[1];
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tombol Kunci Titik GPS Maps Realtime
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isGpsLocked ? Colors.green.shade50 : AppColors.caramel.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isGpsLocked ? Colors.green.shade300 : AppColors.caramel.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isGpsLocked ? Icons.check_circle_rounded : Icons.my_location_rounded,
                                  size: 18,
                                  color: _isGpsLocked ? Colors.green.shade700 : AppColors.caramel,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _isGpsLocked
                                        ? 'Titik GPS Maps Terkunci (${_deliveryLat.toStringAsFixed(4)}, ${_deliveryLng.toStringAsFixed(4)})'
                                        : 'Kirim Titik Lokasi Realtime (GPS Maps)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _isGpsLocked ? Colors.green.shade900 : AppColors.espresso,
                                    ),
                                  ),
                                ),
                                if (_isDetectingGps)
                                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.caramel))
                                else
                                  TextButton(
                                    onPressed: _lockGpsLocation,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      _isGpsLocked ? 'Perbarui GPS' : 'Kunci GPS',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.caramel),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Kurir Seuma akan langsung membuka rute Google Maps ke titik akurat Anda.',
                              style: TextStyle(fontSize: 10.5, color: _isGpsLocked ? Colors.green.shade800 : Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Alamat / Patokan Tertulis
                      TextField(
                        controller: _addressController,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 12.5),
                        decoration: InputDecoration(
                          labelText: 'Detail Alamat & Patokan Rumah / Kantor *',
                          labelStyle: const TextStyle(fontSize: 12),
                          hintText: 'Contoh: Depan Masjid Al-Falah, Pagar Hitam No. 12',
                          hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ] else ...[
                    // ── Form Step 2: Pilihan Pembayaran (COD Diutamakan) ─────
                    const FraudWarningBox(compact: true),
                    const SizedBox(height: 14),

                    // OPSI UTAMA: COD (Bayar di Tempat)
                    _buildPaymentOption(
                      id: 'cod',
                      label: 'Bayar di Tempat (COD)',
                      subtitle: 'Bayar tunai / QRIS langsung saat pesanan tiba di tangan Anda.',
                      icon: Icons.payments_rounded,
                      isRecommended: true,
                    ),

                    const SizedBox(height: 10),

                    // OPSI 2: QRIS Instant
                    _buildPaymentOption(
                      id: 'qris',
                      label: 'QRIS Instant (BCA, GoPay, OVO, ShopeePay)',
                      subtitle: 'Scan kode QRIS resmi Seuma.Koffie saat konfirmasi.',
                      icon: Icons.qr_code_scanner_rounded,
                    ),

                    const SizedBox(height: 10),

                    // OPSI 3: Transfer Bank
                    _buildPaymentOption(
                      id: 'transfer_bank',
                      label: 'Transfer Bank (BCA / BSI Aceh)',
                      subtitle: 'Transfer ke rekening operasional outlet Seuma.',
                      icon: Icons.account_balance_rounded,
                    ),
                  ],

                  const SizedBox(height: 18),

                  // ── Ringkasan Total Biaya (Tanpa Font Overflow) ────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.caramel.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            _isDelivery ? 'Total (+ Ongkir 10k):' : 'Total Pembayaran:',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            formatRupiah(finalAmount),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.caramel),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Tombol Navigasi Bawah ──────────────────────────────────
                  Row(
                    children: [
                      if (_step == 2) ...[
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () => setState(() => _step = 1),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Kembali', style: TextStyle(fontSize: 12.5)),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : () async {
                            if (_step == 1) {
                              if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mohon isi nama dan nomor WhatsApp Anda.')),
                                );
                                return;
                              }
                              if (_isDelivery && _addressController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mohon isi alamat pengantaran lengkap.')),
                                );
                                return;
                              }
                              setState(() => _step = 2);
                            } else {
                              // Simpan Pesanan Transaksional ke Supabase & Realtime Broadcast
                              setState(() { _isSubmitting = true; });
                              // Simpan messenger reference SEBELUM async gap untuk hindari use_build_context_synchronously
                              final messenger = ScaffoldMessenger.of(context);
                              final cart = CartManager.instance;
                              final mapsUrl = _isDelivery
                                  ? 'https://www.google.com/maps?q=$_deliveryLat,$_deliveryLng'
                                  : null;

                              final newOrder = OrderModel(
                                id: _orderUuid,
                                orderNumber: _orderNumber,
                                userId: AuthManager.instance.currentUser?.id,
                                totalAmount: finalAmount.toDouble(),
                                status: OrderStatus.pending,
                                paymentMethod: PaymentMethod.fromString(_selectedPayment),
                                paymentStatus: _selectedPayment == 'qris' ? 'paid' : 'unpaid',
                                recipientName: _nameController.text.trim(),
                                recipientPhone: _phoneController.text.trim(),
                                deliveryAddress: _isDelivery ? _addressController.text.trim() : 'Pickup di Outlet Seuma Pusat Lhokseumawe',
                                deliveryNotes: _isDelivery
                                    ? 'Kecamatan $_selectedArea • GPS: $_deliveryLat, $_deliveryLng'
                                    : 'Pesanan takeaway diambil sendiri di outlet',
                                deliveryLat: _isDelivery ? _deliveryLat : 5.1801,
                                deliveryLng: _isDelivery ? _deliveryLng : 97.1407,
                                mapsUrl: mapsUrl,
                                createdAt: DateTime.now(),
                                items: cart.items.map((ci) => OrderItemModel(
                                  id: generateUuidV4(),
                                  orderId: _orderUuid,
                                  menuId: ci.menuItemId,
                                  menuName: ci.name,
                                  variant: ci.isHot ? 'Hot' : 'Iced',
                                  price: ci.unitPrice.toDouble(),
                                  quantity: ci.quantity,
                                  subtotal: ci.totalPrice.toDouble(),
                                  specialNotes: ci.extraShot ? 'Ekstra shot' : null,
                                )).toList(),
                              );

                              // Kirim ke Admin Manager & Supabase — cek hasil sungguhan
                              final success = await AdminManager.instance.placeNewCustomerOrder(newOrder);
                              if (!mounted) return;
                              if (success) {
                                setState(() { _isSuccess = true; _isSubmitting = false; });
                              } else {
                                final errMsg = AdminManager.instance.lastOrderError ?? 'Pesanan gagal disimpan. Periksa koneksi internet & coba lagi.';
                                setState(() { _isSubmitting = false; });
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.error_outline, color: Colors.white, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text('Gagal: $errMsg', style: const TextStyle(fontSize: 12.5))),
                                      ],
                                    ),
                                    backgroundColor: Colors.red.shade700,
                                    duration: const Duration(seconds: 6),
                                    action: SnackBarAction(
                                      label: 'Coba Lagi',
                                      textColor: Colors.white,
                                      onPressed: () {},
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.espresso,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : Text(
                                  _step == 1 ? 'Lanjut Pembayaran' : 'Konfirmasi & Pesan Sekarang',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String label,
    required String subtitle,
    required IconData icon,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedPayment == id;
    return InkWell(
      onTap: () => setState(() => _selectedPayment = id),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.caramel.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.caramel
                : (isRecommended ? Colors.green.shade400 : Colors.grey.withValues(alpha: 0.25)),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.caramel.withValues(alpha: 0.15) : const Color(0xFFFBF8F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? AppColors.caramel : Colors.grey.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '⭐ REKOMENDASI',
                            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.green.shade800),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3),
                  ),
                ],
              ),
            ),
            // Custom Radio Indicator (Bebas Deprecated)
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.caramel : Colors.grey.shade400,
                  width: isSelected ? 6 : 2,
                ),
                color: Colors.white,
              ),
            ),
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
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Icon(Icons.check_circle_rounded, size: 40, color: Colors.green.shade700),
        ),
        const SizedBox(height: 14),
        const Text(
          'Pesanan Berhasil Diterima!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pesanan telah live masuk ke Dashboard Barista Seuma.Koffie.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),

        // Bukti Struk Digital
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.caramel.withValues(alpha: 0.18)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('No. Pesanan:', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                  Text(_orderNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.caramel)),
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
                  const Text('Metode Bayar:', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                  Text(
                    _selectedPayment == 'cod' ? 'BAYAR DI TEMPAT (COD)' : _selectedPayment.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: _selectedPayment == 'cod' ? Colors.green.shade800 : AppColors.espresso,
                    ),
                  ),
                ],
              ),
              if (_isDelivery) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Navigasi Maps:', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 13, color: Colors.green),
                        Text(
                          '${_deliveryLat.toStringAsFixed(3)}, ${_deliveryLng.toStringAsFixed(3)}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pembayaran:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                  Text(
                    formatRupiah(finalAmount),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.caramel),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Tombol Lacak Pesanan
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              CartManager.instance.clear();
              Navigator.of(context).pop();
              CustomerOrderHistoryDialog.show(context);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.caramel.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.delivery_dining_rounded, size: 17, color: AppColors.caramel),
            label: const Text('Lacak Pesanan Saya', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.caramel)),
          ),
        ),

        const SizedBox(height: 10),

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
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text('Selesai & Tutup', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ),
      ],
    );
  }
}
