// lib/widgets/pro/flash_deals_section.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../theme/app_theme.dart';

class FlashDealsSection extends StatefulWidget {
  final List<MenuItem> items;
  final ValueChanged<MenuItem> onAddToCart;

  const FlashDealsSection({
    super.key,
    required this.items,
    required this.onAddToCart,
  });

  @override
  State<FlashDealsSection> createState() => _FlashDealsSectionState();
}

class _FlashDealsSectionState extends State<FlashDealsSection> {
  late Timer _timer;
  Duration _timeLeft = const Duration(hours: 3, minutes: 24, seconds: 18);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft.inSeconds > 0) {
            _timeLeft = _timeLeft - const Duration(seconds: 1);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final flashItems = widget.items.take(4).toList();
    if (flashItems.isEmpty) return const SizedBox.shrink();

    final hours = _formatDigits(_timeLeft.inHours);
    final minutes = _formatDigits(_timeLeft.inMinutes.remainder(60));
    final seconds = _formatDigits(_timeLeft.inSeconds.remainder(60));

    return Container(
      width: double.infinity,
      color: const Color(0xFFFBF6EE),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 16,
        vertical: 36,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Flash Deal Title + Countdown Timer
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE53935).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'FLASH SALE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Promo Kilat Khusus Warga Lhokseumawe',
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.espresso,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Countdown Box
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTimerDigit(hours),
                      const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      _buildTimerDigit(minutes),
                      const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      _buildTimerDigit(seconds),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Cards Layout (Grid / Scrollable)
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: flashItems.map((item) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _buildFlashCard(item),
                          ),
                        );
                      }).toList(),
                    )
                  : SizedBox(
                      height: 245,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: flashItems.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 175,
                            child: _buildFlashCard(flashItems[index]),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDigit(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF261004),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildFlashCard(MenuItem item) {
    final originalPrice = item.price * 1.35;
    final discountPercent = 25;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.caramel.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon visual with Discount Pill
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.cream.withValues(alpha: 0.5),
                      AppColors.gold.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item.imageAsset,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '-$discountPercent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: AppColors.espresso,
            ),
          ),

          const SizedBox(height: 4),

          // Price row: Discounted Price + Strikethrough
          Row(
            children: [
              Text(
                item.formattedPrice,
                style: const TextStyle(
                  color: AppColors.caramel,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Rp ${originalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Scarcity Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.82,
              minHeight: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🔥 Terjual 82%',
                style: TextStyle(fontSize: 9, color: Color(0xFFE53935), fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () => widget.onAddToCart(item),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.caramel,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

