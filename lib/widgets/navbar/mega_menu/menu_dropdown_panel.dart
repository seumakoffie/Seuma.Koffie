// lib/widgets/navbar/mega_menu/menu_dropdown_panel.dart
import 'package:flutter/material.dart';
import '../../../models/menu_item.dart';
import '../../../theme/app_theme.dart';

class MenuDropdownPanel extends StatelessWidget {
  final ValueChanged<String>? onSelectCategory;
  final VoidCallback onExploreMenu;
  final VoidCallback onOrderNow;
  final VoidCallback onClose;

  const MenuDropdownPanel({
    super.key,
    required this.onSelectCategory,
    required this.onExploreMenu,
    required this.onOrderNow,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Get official categories from kCategories model (excluding 'all')
    final categories = kCategories.where((c) => c.slug != 'all').toList();

    final featured = [
      {'emoji': '🥛', 'name': 'Hot Sanger Espresso', 'price': 'Rp 10.000', 'tag': '🏆 #1 Bestseller'},
      {'emoji': '🧋', 'name': 'Kopi Susu Aren', 'price': 'Rp 15.000', 'tag': '❤️ Favorit'},
      {'emoji': '🍃', 'name': 'Matcha Latte', 'price': 'Rp 18.000', 'tag': '✨ Baru'},
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Col 1: Kategori Menu (Synchronized with kCategories slugs!)
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('KATEGORI MENU'),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        onClose();
                        onSelectCategory?.call(cat.slug);
                        onExploreMenu();
                      },
                      child: Container(
                        width: 170,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Text(cat.iconEmoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    cat.subtitle,
                                    style: TextStyle(
                                      color: AppColors.cream.withValues(alpha: 0.6),
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(width: 32),

        // Col 2: Pilihan Terbaik
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('PILIHAN TERBAIK'),
              const SizedBox(height: 14),
              ...featured.map((item) {
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      onClose();
                      onOrderNow();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.caramel.withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Text(item['emoji']!, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['tag']!,
                                  style: const TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  item['name']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  item['price']!,
                                  style: const TextStyle(
                                    color: AppColors.caramel,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.caramel,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(width: 32),

        // Col 3: Pesan Cepat
        SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('PESAN CEPAT'),
              const SizedBox(height: 14),
              _buildQuickActionBtn(
                Icons.shopping_bag_outlined,
                'Pesan Sekarang',
                AppColors.caramel,
                () {
                  onClose();
                  onOrderNow();
                },
              ),
              const SizedBox(height: 10),
              _buildQuickActionBtn(
                Icons.menu_book_rounded,
                'Lihat Semua Menu',
                Colors.transparent,
                () {
                  onClose();
                  onExploreMenu();
                },
                outlined: true,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚡ Antar Cepat',
                      style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '15–20 Menit ke seluruh Lhokseumawe & Sekitarnya',
                      style: TextStyle(color: AppColors.cream.withValues(alpha: 0.7), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.gold.withValues(alpha: 0.9),
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildQuickActionBtn(IconData icon, String label, Color bg, VoidCallback onTap, {bool outlined = false}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : bg,
            borderRadius: BorderRadius.circular(10),
            border: outlined ? Border.all(color: Colors.white.withValues(alpha: 0.3)) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: outlined ? AppColors.cream : Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: outlined ? AppColors.cream : Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
