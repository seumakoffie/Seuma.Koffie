// lib/widgets/cart_drawer.dart
import 'package:flutter/material.dart';
import '../state/cart_state.dart';
import '../state/auth_state.dart';
import '../theme/app_theme.dart';
import 'checkout_dialog.dart';
import 'auth_dialog.dart';
import 'common/fraud_warning_box.dart';

class CartDrawer extends StatefulWidget {
  const CartDrawer({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CartDrawer',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (context, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
      pageBuilder: (context, _, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final drawerWidth = screenWidth > 500 ? 440.0 : screenWidth * 0.92;

        return Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: drawerWidth,
            height: double.infinity,
            child: const Material(
              color: Colors.white,
              child: CartDrawer(),
            ),
          ),
        );
      },
    );
  }

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> {
  final TextEditingController _voucherController = TextEditingController();

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartManager.instance,
      builder: (context, _) {
        final cart = CartManager.instance;
        final items = cart.items;

        return SafeArea(
          child: Column(
            children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: AppColors.caramel, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'Keranjang Belanja',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.caramel.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${cart.totalItems}',
                          style: const TextStyle(
                            color: AppColors.caramel,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            // Item List or Empty State
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: AppColors.creamLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('☕', style: TextStyle(fontSize: 40)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Keranjang Masih Kosong',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pilih minuman favoritmu dari daftar menu.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.caramel.withValues(alpha: 0.12)),
                          ),
                          child: Row(
                            children: [
                              // Thumbnail (Foto Menu atau Emoji)
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: item.hasImage
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.asset(
                                            item.imagePath!,
                                            width: 38,
                                            height: 38,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => Text(item.iconEmoji, style: const TextStyle(fontSize: 22)),
                                          ),
                                        )
                                      : Text(item.iconEmoji, style: const TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          item.isHot ? '🔥 HOT' : '🧊 ICE',
                                          style: TextStyle(
                                            color: item.isHot ? AppColors.hotRed : AppColors.iceBlue,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          formatRupiah(item.unitPrice),
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Qty Controls
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => cart.updateQuantity(item.id, -1),
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                                      ),
                                      child: const Icon(Icons.remove, size: 14),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => cart.updateQuantity(item.id, 1),
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: AppColors.caramel,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Footer / Voucher & Checkout
            if (items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Price Breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal Minuman:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        Text(formatRupiah(cart.subtotal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if (cart.discount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Diskon Voucher (${cart.appliedVoucher}):',
                              style: const TextStyle(fontSize: 12, color: AppColors.successGreen)),
                          Text('- ${formatRupiah(cart.discount)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.successGreen)),
                        ],
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                        Text(
                          formatRupiah(cart.grandTotal),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.caramel),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Info Waspada Penipuan
                    const FraudWarningBox(compact: true),

                    const SizedBox(height: 16),

                    // Checkout CTA (Protected with Auth Guard v5.0)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (!AuthManager.instance.isLoggedIn) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⚠️ Harap daftar akun atau masuk terlebih dahulu sebelum melakukan pemesanan.'),
                                backgroundColor: AppColors.caramel,
                              ),
                            );
                            AuthDialog.show(
                              context,
                              isRegister: true,
                              reasonMessage: 'Harap daftar atau masuk akun terlebih dahulu untuk melanjutkan pemesanan kopi.',
                              onAuthSuccess: () {
                                CheckoutDialog.show(context);
                              },
                            );
                          } else {
                            CheckoutDialog.show(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.caramel,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text(
                          'Lanjut ke Pembayaran',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        );
      },
    );
  }
}
