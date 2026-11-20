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

  List<Color> _getCategoryGradient(String slug) {
    switch (slug) {
      case 'matcha':
        return [const Color(0xFF1B5E20), const Color(0xFF4CAF50), const Color(0xFFA5D6A7)];
      case 'taro':
      case 'velvet':
        return [const Color(0xFF4A148C), const Color(0xFF9C27B0), const Color(0xFFCE93D8)];
      case 'squash':
        return [const Color(0xFFBF360C), const Color(0xFFFF7043), const Color(0xFFFFCCBC)];
      case 'sanger':
      case 'espresso':
        return [const Color(0xFF1A0A00), const Color(0xFF4E342E), const Color(0xFFA1887F)];
      case 'americano':
        return [const Color(0xFF2D1B10), const Color(0xFF5D4037), const Color(0xFFBCAAA4)];
      case 'susu':
      case 'latte':
        return [const Color(0xFF4E342E), const Color(0xFF8D6E63), const Color(0xFFD7CCC8)];
      case 'saku':
        return [const Color(0xFF8B5E00), const Color(0xFFD48B38), const Color(0xFFFFE0B2)];
      default:
        return [const Color(0xFF6B3A1F), AppColors.caramel, const Color(0xFFFFE0B2)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasHot = item.priceHot != null;
    final hasIce = item.priceIce != null;
    final themeColor = _getCategoryThemeColor(item.categorySlug);
    final gradientColors = _getCategoryGradient(item.categorySlug);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered
                  ? themeColor.withValues(alpha: 0.55)
                  : AppColors.caramel.withValues(alpha: 0.12),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HERO IMAGE STAGE ──────────────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.55, 1.0],
                          colors: [
                            gradientColors[0],
                            gradientColors[1],
                            gradientColors[2],
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // ── Concentric Glow Rings (ambient halo) ──
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            width: _isHovered ? 160 : 130,
                            height: _isHovered ? 160 : 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: _isHovered ? 0.18 : 0.10),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: _isHovered ? 110 : 90,
                            height: _isHovered ? 110 : 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: _isHovered ? 0.25 : 0.14),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                      // ── Elliptical "table surface" shadow under drink ──
                      Positioned(
                        bottom: 14,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          width: _isHovered ? 110 : 90,
                          height: _isHovered ? 18 : 14,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: _isHovered ? 0.38 : 0.28),
                                blurRadius: _isHovered ? 20 : 14,
                                spreadRadius: _isHovered ? 2 : 0,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Floating Drink Image ──
                      Positioned(
                        bottom: 20,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 250),
                          scale: _isHovered ? 1.12 : 1.0,
                          curve: Curves.easeOutBack,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                // Primary depth shadow
                                BoxShadow(
                                  color: gradientColors[0].withValues(alpha: _isHovered ? 0.65 : 0.45),
                                  blurRadius: _isHovered ? 28 : 18,
                                  offset: const Offset(0, 10),
                                  spreadRadius: -2,
                                ),
                                // Secondary soft glow
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: _isHovered ? 0.20 : 0.10),
                                  blurRadius: 8,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: item.hasImage
                                ? Image.asset(
                                    item.resolvedImagePath!,
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => Text(
                                      item.iconEmoji,
                                      style: const TextStyle(fontSize: 72),
                                    ),
                                  )
                                : Text(
                                    item.iconEmoji,
                                    style: const TextStyle(fontSize: 72),
                                  ),
                          ),
                        ),
                      ),

                      // ── Light streak (top-left highlight for 3D feel) ──
                      Positioned(
                        top: 10,
                        left: 18,
                        child: Container(
                          width: 60,
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.55),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Badges overlay di atas ClipRRect ──
              _buildBadgesOverlay(item, hasHot, hasIce),
                ],
              ),

              // ── BOTTOM DETAILS ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
                            color: themeColor.withValues(alpha: 0.9),
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

                    // Volume Sold Indicator
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

                        // Plus Add Button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: !item.isAvailable
                                ? null
                                : (_isHovered ? AppColors.caramelGradient : null),
                            color: !item.isAvailable
                                ? Colors.grey.shade300
                                : (_isHovered ? null : themeColor.withValues(alpha: 0.14)),
                            shape: BoxShape.circle,
                            boxShadow: item.isAvailable && _isHovered
                                ? [
                                    BoxShadow(
                                      color: AppColors.caramel.withValues(alpha: 0.45),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: Icon(
                            !item.isAvailable ? Icons.block_rounded : Icons.add_shopping_cart_rounded,
                            size: 16,
                            color: !item.isAvailable
                                ? Colors.grey.shade600
                                : (_isHovered ? Colors.white : themeColor),
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

  // ── Badges row helper (Best Seller, New, Hot, Ice) ──
  Widget _buildBadgesOverlay(MenuItem item, bool hasHot, bool hasIce) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!item.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Text(
                      'HABIS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                if (item.isBestSeller && item.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.caramelGradient,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.caramel.withValues(alpha: 0.4),
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
                      color: Colors.teal.shade600,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
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
            // Right thermal badges
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasHot)
                  Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
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
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
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
          ],
        ),
      ),
    );
  }
}
