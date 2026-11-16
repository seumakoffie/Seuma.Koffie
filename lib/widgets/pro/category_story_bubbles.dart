// lib/widgets/pro/category_story_bubbles.dart
import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../theme/app_theme.dart';

class CategoryStoryBubbles extends StatelessWidget {
  final String selectedSlug;
  final ValueChanged<String> onSelectCategory;

  const CategoryStoryBubbles({
    super.key,
    required this.selectedSlug,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 18),
            itemBuilder: (context, index) {
              final cat = kCategories[index];
              final isSelected = cat.slug == selectedSlug;

              return _buildStoryBubble(cat, isSelected);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStoryBubble(CategoryInfo category, bool isSelected) {
    return GestureDetector(
      onTap: () => onSelectCategory(category.slug),
      child: SizedBox(
        width: 74,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Ring with Gradient
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFE53935), AppColors.caramel, AppColors.gold],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.grey.shade300,
                          Colors.grey.shade200,
                        ],
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.caramel.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: isSelected
                      ? AppColors.cream.withValues(alpha: 0.5)
                      : Colors.grey.shade100,
                  child: Text(
                    category.iconEmoji,
                    style: TextStyle(
                      fontSize: category.slug == 'all' ? 18 : 22,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Label
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.espresso : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
