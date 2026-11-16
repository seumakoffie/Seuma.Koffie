// lib/screens/home/widgets/menu_catalog_section.dart
import 'package:flutter/material.dart';
import '../../../models/menu_item.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/menu_card.dart';
import '../../../widgets/product_dialog.dart';

class MenuCatalogSection extends StatelessWidget {
  final GlobalKey sectionKey;
  final String selectedCategorySlug;
  final String searchQuery;
  final List<MenuItem> filteredMenuItems;
  final ValueChanged<String> onSelectCategory;
  final ValueChanged<String> onSearchChanged;

  const MenuCatalogSection({
    super.key,
    required this.sectionKey,
    required this.selectedCategorySlug,
    required this.searchQuery,
    required this.filteredMenuItems,
    required this.onSelectCategory,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    int crossAxisCount = 2;
    double childAspectRatio = 0.60;

    if (screenWidth > 1200) {
      crossAxisCount = 4;
      childAspectRatio = 0.74;
    } else if (screenWidth > 900) {
      crossAxisCount = 3;
      childAspectRatio = 0.72;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
      childAspectRatio = 0.66;
    } else if (screenWidth < 350) {
      crossAxisCount = 1;
      childAspectRatio = 1.25;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.60;
    }

    return Column(
      children: [
        // Search & Category Chips Header
        Container(
          key: sectionKey,
          color: AppColors.background,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : 16,
            vertical: 24,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.caramel.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'PILIHAN MENU LENGKAP',
                              style: TextStyle(
                                color: AppColors.caramel,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Daftar Menu Favorit',
                            style: TextStyle(
                              fontSize: isDesktop ? 28 : 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${filteredMenuItems.length} Menu',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Search Bar
                  TextField(
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Cari kopi susu, sanger, matcha, squash...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.caramel.withValues(alpha: 0.15)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.caramel.withValues(alpha: 0.15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.caramel.withValues(alpha: 0.5), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category Chips (horizontal scrollable)
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: kCategories.map<Widget>((cat) {
                        final isSelected = selectedCategorySlug == cat.slug;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => onSelectCategory(cat.slug),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: isSelected ? AppColors.caramelGradient : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : AppColors.caramel.withValues(alpha: 0.2),
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: AppColors.caramel.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Text(cat.iconEmoji, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.textDark,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Menu Grid
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : 16,
            vertical: 8,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: filteredMenuItems.isEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      alignment: Alignment.center,
                      child: const Column(
                        children: [
                          Text('🔍', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text(
                            'Menu tidak ditemukan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Coba kata kunci lain atau pilih kategori Semua.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: isDesktop ? 20 : 12,
                        mainAxisSpacing: isDesktop ? 20 : 12,
                      ),
                      itemCount: filteredMenuItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredMenuItems[index];
                        return MenuCard(
                          item: item,
                          onTap: () => ProductDialog.show(context, item),
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
