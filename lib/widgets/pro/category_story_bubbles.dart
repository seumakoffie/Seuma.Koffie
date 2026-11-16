// lib/widgets/pro/category_story_bubbles.dart
// Interactive Category Story Bubbles with Slider Controls, Animated Glowing Rings & Smooth Auto-Scroll
import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../theme/app_theme.dart';

class CategoryStoryBubbles extends StatefulWidget {
  final String selectedSlug;
  final ValueChanged<String> onSelectCategory;

  const CategoryStoryBubbles({
    super.key,
    required this.selectedSlug,
    required this.onSelectCategory,
  });

  @override
  State<CategoryStoryBubbles> createState() => _CategoryStoryBubblesState();
}

class _CategoryStoryBubblesState extends State<CategoryStoryBubbles>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll(double offset) {
    _scrollController.animateTo(
      (_scrollController.offset + offset).clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isDesktop = sw > 700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          height: 115,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── HORIZONTAL SCROLLABLE STORY BUBBLES ──────────────────────
              ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
                itemCount: kCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  final cat = kCategories[index];
                  final isSelected = cat.slug == widget.selectedSlug;

                  return _buildAnimatedStoryBubble(cat, isSelected);
                },
              ),

              // ── SLIDER PREV BUTTON (<) ───────────────────────────────────
              if (isDesktop)
                Positioned(
                  left: 6,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _scroll(-240),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.espresso,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

              // ── SLIDER NEXT BUTTON (>) ───────────────────────────────────
              if (isDesktop)
                Positioned(
                  right: 6,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _scroll(240),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.espresso,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStoryBubble(CategoryInfo category, bool isSelected) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulseScale = isSelected ? (1.0 + (_pulseController.value * 0.06)) : 1.0;

        return GestureDetector(
          onTap: () => widget.onSelectCategory(category.slug),
          child: SizedBox(
            width: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Animated Outer Ring
                Transform.scale(
                  scale: pulseScale,
                  child: Container(
                    padding: const EdgeInsets.all(2.8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFFF5722), // Vibrant Coral
                                AppColors.caramel,
                                Color(0xFFFFD54F), // Bright Gold
                              ],
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
                                color: AppColors.caramel.withValues(alpha: 0.45),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2.2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: CircleAvatar(
                        radius: 27,
                        backgroundColor: isSelected
                            ? AppColors.creamLight
                            : Colors.grey.shade100,
                        child: Text(
                          category.iconEmoji,
                          style: TextStyle(
                            fontSize: category.slug == 'all' ? 20 : 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Category Title
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    color: isSelected ? AppColors.espresso : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
