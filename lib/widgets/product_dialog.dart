// lib/widgets/product_dialog.dart
import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';

class ProductDialog extends StatefulWidget {
  final MenuItem item;

  const ProductDialog({super.key, required this.item});

  static Future<void> show(BuildContext context, MenuItem item) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.90,
          ),
          child: ProductDialog(item: item),
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (ctx) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 440,
              maxHeight: MediaQuery.of(ctx).size.height * 0.90,
            ),
            child: Material(
              color: Colors.transparent,
              child: ProductDialog(item: item),
            ),
          ),
        ),
      );
    }
  }

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  late bool _isHot;
  bool _addShot = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.item.tempOption == TempOption.hotOnly) {
      _isHot = true;
    } else {
      _isHot = false;
    }
  }

  int get _calculatedUnitPrice {
    final item = widget.item;
    int base = 0;
    if (item.priceFixed != null) {
      base = item.priceFixed!;
    } else if (_isHot && item.priceHot != null) {
      base = item.priceHot!;
    } else if (!_isHot && item.priceIce != null) {
      base = item.priceIce!;
    } else {
      base = item.startingPrice;
    }

    if (_addShot) {
      base += 3000;
    }
    return base;
  }

  int get _totalPrice => _calculatedUnitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasBoth = item.tempOption == TempOption.both;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.softShadow,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.creamLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.caramel.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: item.hasImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                item.resolvedImagePath!,
                                width: 50,
                                height: 50,
                                cacheWidth: 150,
                                cacheHeight: 150,
                                filterQuality: FilterQuality.medium,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Text(
                                  item.iconEmoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            )
                          : Text(item.iconEmoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.caramel,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
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

          const SizedBox(height: 14),

          // Description
          Text(
            item.description,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 18),

          // Temperature Selector (HOT / ICE)
          if (hasBoth) ...[
            const Text(
              'PILIH SUHU PENYAJIAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isHot = true),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isHot ? AppColors.hotRed.withValues(alpha: 0.12) : AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isHot ? AppColors.hotRed : Colors.grey.withValues(alpha: 0.2),
                          width: _isHot ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: _isHot ? AppColors.hotRed : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'HOT (${formatRupiah(item.priceHot!)})',
                            style: TextStyle(
                              color: _isHot ? AppColors.hotRed : AppColors.textDark,
                              fontSize: 12,
                              fontWeight: _isHot ? FontWeight.w800 : FontWeight.w600,
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
                    onTap: () => setState(() => _isHot = false),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isHot ? AppColors.iceBlue.withValues(alpha: 0.12) : AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: !_isHot ? AppColors.iceBlue : Colors.grey.withValues(alpha: 0.2),
                          width: !_isHot ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.ac_unit,
                            color: !_isHot ? AppColors.iceBlue : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ICE (${formatRupiah(item.priceIce!)})',
                            style: TextStyle(
                              color: !_isHot ? AppColors.iceBlue : AppColors.textDark,
                              fontSize: 12,
                              fontWeight: !_isHot ? FontWeight.w800 : FontWeight.w600,
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
          ],

          // Additional Espresso Shot Option
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.caramel.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ekstra Espresso Shot (+3k)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Rasa kopi lebih pekat & nendang',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: _addShot,
                  activeTrackColor: AppColors.caramel,
                  onChanged: (val) => setState(() => _addShot = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Quantity Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jumlah Pesanan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove, size: 16),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.background,
                      foregroundColor: AppColors.textDark,
                    ),
                  ),
                  Container(
                    width: 36,
                    alignment: Alignment.center,
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add, size: 16),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.caramel.withValues(alpha: 0.15),
                      foregroundColor: AppColors.caramel,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Add to cart CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: !item.isAvailable
                  ? null
                  : () {
                      CartManager.instance.addItem(
                        menuItemId: item.id,
                        name: item.name,
                        category: item.category,
                        isHot: _isHot,
                        extraShot: _addShot,
                        unitPrice: _calculatedUnitPrice,
                        quantity: _quantity,
                        iconEmoji: item.iconEmoji,
                      );

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.espresso,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          content: Row(
                            children: [
                              Text(item.iconEmoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '$_quantity x ${item.name} berhasil ditambah!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: !item.isAvailable ? Colors.grey.shade400 : AppColors.caramel,
                foregroundColor: Colors.white,
                elevation: !item.isAvailable ? 0 : 4,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(!item.isAvailable ? Icons.block_rounded : Icons.shopping_bag_outlined, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        !item.isAvailable ? 'Menu Sedang Habis' : 'Tambah ke Keranjang',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  if (item.isAvailable)
                    Text(
                      formatRupiah(_totalPrice),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
