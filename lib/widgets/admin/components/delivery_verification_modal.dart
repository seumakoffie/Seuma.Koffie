// lib/widgets/admin/components/delivery_verification_modal.dart
import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../theme/app_theme.dart';
import '../../../state/admin_state.dart';
import '../../../state/auth_state.dart';

class DeliveryVerificationModal extends StatefulWidget {
  final OrderModel order;

  const DeliveryVerificationModal({super.key, required this.order});

  static Future<bool?> show(BuildContext context, OrderModel order) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeliveryVerificationModal(order: order),
    );
  }

  @override
  State<DeliveryVerificationModal> createState() => _DeliveryVerificationModalState();
}

class _DeliveryVerificationModalState extends State<DeliveryVerificationModal> {
  late final TextEditingController _recipientCtrl;
  late final TextEditingController _notesCtrl;
  bool _isSubmitting = false;
  final String _selectedProof = 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=400';

  @override
  void initState() {
    super.initState();
    _recipientCtrl = TextEditingController(text: widget.order.recipientName);
    _notesCtrl = TextEditingController(text: widget.order.deliveryNotes ?? 'Diterima dalam kondisi hangat & higienis.');
  }

  @override
  void dispose() {
    _recipientCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final recipient = _recipientCtrl.text.trim();
    if (recipient.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi nama penerima pesanan di lokasi.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final admin = AdminManager.instance;
    final verifier = AuthManager.instance.currentUser?.name ?? 'Admin Outlet Seuma';

    final success = await admin.verifyDeliveryAtLocation(
      orderId: widget.order.id,
      recipientName: recipient,
      verifiedByName: verifier,
      proofUrl: _selectedProof,
      deliveryNotes: _notesCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1B5E20),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.verified, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pesanan ${widget.order.orderNumber} berhasil diverifikasi sampai lokasi & disegel ke Blockchain!',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF81C784)),
                        ),
                        child: const Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Verifikasi Sampai di Lokasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.espresso,
                            ),
                          ),
                          Text(
                            widget.order.orderNumber,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.caramel,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Rincian Lokasi Pengantaran
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
                    Row(
                      children: [
                        const Icon(Icons.map_outlined, size: 16, color: AppColors.espresso),
                        const SizedBox(width: 6),
                        const Text(
                          'Tujuan Pengantaran Lhokseumawe:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.espresso),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.order.deliveryAddress,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    if (widget.order.deliveryNotes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Patokan: ${widget.order.deliveryNotes}',
                        style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Form Nama Penerima Langsung
              const Text(
                'Nama Penerima di Lokasi *',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.espresso),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _recipientCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  hintText: 'Contoh: Rahmat Hidayat (Pemesan langsung)',
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),

              const SizedBox(height: 14),

              // Catatan Serah Terima
              const Text(
                'Catatan Serah Terima / Kondisi Paket',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.espresso),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Contoh: Diterima langsung, kemasan segel aman.',
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),

              const SizedBox(height: 16),

              // Banner Blockchain Timestamp & Segel Kriptografi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFAED581)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: Color(0xFF33691E), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SEGMEN BLOCKCHAIN & SHA-256 PROOF',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF33691E)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Waktu dan koordinat akan otomatis disegel ke immutable ledger database Supabase saat tombol ditekan.',
                            style: TextStyle(fontSize: 11, color: Colors.green.shade900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tombol Konfirmasi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Verifikasi Tiba di Lokasi',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
