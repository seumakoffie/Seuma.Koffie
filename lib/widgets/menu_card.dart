// lib/widgets/menu_card.dart
import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';

class MenuCard extends StatefulWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  bool _isHovered = false;

  Color _getCategoryThemeColor(String slug) {
    switch (slug) {
      case 'matcha':
        return const Color(0xFF2E7D32);
      case 'taro':
      case 'velvet':
        return const Color(0xFF6A1B9A);
      case 'squash':
        return const Color(0xFFEF6C00);
      case 'sanger':
      case 'espresso':
      case 'americano':
        return const Color(0xFF4E342E);
      case 'susu':
      case 'latte':
        return const Color(0xFF8D6E63);
      case 'saku':
        return const Color(0xFFD48B38);
      default:
        return AppColors.caramel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasHot = item.priceHot != null;
    final hasIce = item.priceIce != null;
    final themeColor = _getCategoryThemeColor(item.categorySlug);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _isHovered ? -5.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered
                  ? AppColors.caramel.withValues(alpha: 0.5)
                  : AppColors.caramel.withValues(alpha: 0.12),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: _isHovered ? AppColors.hoverShadow : AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner / Thumbnail Area with Themed Ambient Stage
              Stack(
                children: [
                  Container(
                    height: 125,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          themeColor.withValues(alpha: 0.12),
                          AppColors.creamLight,
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft Ambient Backlight Halo
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _isHovered ? 85 : 70,
                          height: _isHovered ? 85 : 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: themeColor.withValues(alpha: _isHovered ? 0.22 : 0.12),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withValues(alpha: _isHovered ? 0.35 : 0.15),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                        ),

                        // Animated Drink Visual
                        AnimatedScale(
                          duration: const Duration(milliseconds: 220),
                          scale: _isHovered ? 1.15 : 1.0,
                          child: Text(
                            item.iconEmoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top Left Badges (Best Seller / New / Official)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.isBestSeller)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              gradient: AppColors.caramelGradient,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.caramel.withValues(alpha: 0.35),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_fire_department, size: 10, color: Colors.white),
                                SizedBox(width: 3),
                                Text(
                                  'TERLARIS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (item.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade700,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'BARU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Top Right Thermal Badges (Hot / Ice)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasHot)
                          Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_fire_department_rounded,
                              size: 11,
                              color: Colors.deepOrange,
                            ),
                          ),
                        if (hasIce)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.ac_unit_rounded,
                              size: 11,
                              color: Colors.lightBlue.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // Bottom Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.category.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.caramel.withValues(alpha: 0.9),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                            SizedBox(width: 2),
                            Text(
                              '4.9',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // Name
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Description
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.85),
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Volume Sold Indicator (Social proof marketplace)
                    Text(
                      '1.2k+ terjual di Lhokseumawe',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Price & Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.priceHot != null && item.priceIce != null ? 'Mulai dari' : 'Harga',
                              style: TextStyle(
                                color: AppColors.textMuted.withValues(alpha: 0.7),
                                fontSize: 9.5,
                              ),
                            ),
                            Text(
                              formatRupiah(item.startingPrice),
                              style: const TextStyle(
                                color: AppColors.caramel,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),

                        // Plus Add Button with ripple
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: _isHovered ? AppColors.caramelGradient : null,
                            color: _isHovered ? null : AppColors.caramel.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            boxShadow: _isHovered
                                ? [
                                    BoxShadow(
                                      color: AppColors.caramel.withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 16,
                            color: _isHovered ? Colors.white : AppColors.caramel,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
