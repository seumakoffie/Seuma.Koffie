// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../state/cart_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pro/split_hero_section.dart';
import '../../widgets/pro/category_story_bubbles.dart';
import '../../widgets/navbar/corporate_navbar.dart';
import '../../widgets/pro/about_section_v3.dart';
import '../../widgets/pro/footer_v3.dart';
import '../../widgets/cart_drawer.dart';
import '../../widgets/auth_dialog.dart';
import '../../widgets/auth/welcome_order_prompt_dialog.dart';
import '../../state/auth_state.dart';
import '../../state/menu_state.dart';
import '../../widgets/story_and_quiz_section.dart';
import '../../widgets/customer/live_order_tracker_banner.dart';
import 'widgets/notification_strip.dart';
import 'widgets/menu_catalog_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategorySlug = 'all';
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _menuSectionKey = GlobalKey();
  final GlobalKey _aboutSectionKey = GlobalKey();
  final GlobalKey _footerSectionKey = GlobalKey();
  static bool _hasShownWelcomeDialog = false;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onHomeScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowWelcomePrompt();
    });
  }

  void _onHomeScroll() {
    final scrolled = _scrollController.offset > 20;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }
  }

  void _checkAndShowWelcomePrompt() {
    if (!mounted) return;
    if (!_hasShownWelcomeDialog && !AuthManager.instance.isLoggedIn) {
      _hasShownWelcomeDialog = true;
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted && !AuthManager.instance.isLoggedIn) {
          WelcomeOrderPromptDialog.show(context);
        }
      });
    }
  }

  List<MenuItem> get _filteredMenuItems {
    return MenuManager.instance.items.where((item) {
      final matchesCategory = _selectedCategorySlug == 'all' || item.categorySlug == _selectedCategorySlug;
      final q = _searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _scrollToKey(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onHomeScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── MAIN SCROLL VIEW ─────────────────────────────────────────────
          ListenableBuilder(
            listenable: MenuManager.instance,
            builder: (context, _) {
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Top Notification Strip
                  const SliverToBoxAdapter(
                    child: NotificationStrip(),
                  ),

                  // Spacer for overlaid navbar (64px)
                  const SliverToBoxAdapter(child: SizedBox(height: 64)),

                  // Hero Sanger Cup Section
                  SliverToBoxAdapter(
                    child: SplitHeroSection(
                      onOrderNow: () => _scrollToKey(_menuSectionKey),
                      onExploreMenu: () => _scrollToKey(_menuSectionKey),
                    ),
                  ),

                  // Instagram/Shopee Category Story Bubbles
                  SliverToBoxAdapter(
                    child: CategoryStoryBubbles(
                      selectedSlug: _selectedCategorySlug,
                      onSelectCategory: (slug) {
                        setState(() => _selectedCategorySlug = slug);
                        _scrollToKey(_menuSectionKey);
                      },
                    ),
                  ),

                  // Interactive Taste Quiz Section
                  const SliverToBoxAdapter(
                    child: StoryAndQuizSection(),
                  ),

                  // Modular Menu Catalog Section (Search, Chips, Grid)
                  SliverToBoxAdapter(
                    child: MenuCatalogSection(
                      sectionKey: _menuSectionKey,
                      selectedCategorySlug: _selectedCategorySlug,
                      searchQuery: _searchQuery,
                      filteredMenuItems: _filteredMenuItems,
                      onSelectCategory: (slug) {
                        setState(() => _selectedCategorySlug = slug);
                      },
                      onSearchChanged: (q) {
                        setState(() => _searchQuery = q);
                      },
                    ),
                  ),

                  // About Section v3 (Timeline, Stats, Pillars)
                  SliverToBoxAdapter(
                    child: Container(
                      key: _aboutSectionKey,
                      child: const AboutSectionV3(),
                    ),
                  ),

                  // Corporate Footer v4 (Kredibilitas & Trust Badges)
                  SliverToBoxAdapter(
                    child: Container(
                      key: _footerSectionKey,
                      child: const FooterV3(),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── CORPORATE NAVBAR (Overlaid on top, Smooth Floating Docking) ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            top: _isScrolled ? 0 : 27, // smooth docking when scrolled
            left: 0,
            right: 0,
            child: CorporateNavbar(
              onOrderNow: () => _scrollToKey(_menuSectionKey),
              onExploreMenu: () => _scrollToKey(_menuSectionKey),
              onShowCart: () => CartDrawer.show(context),
              onShowAuth: () => AuthDialog.show(context),
              onScrollToAbout: () => _scrollToKey(_aboutSectionKey),
              onScrollToPromo: () => _scrollToKey(_menuSectionKey),
              onScrollToLocation: () => _scrollToKey(_footerSectionKey),
              onScrollToTop: _scrollToTop,
              onSelectCategory: (slug) {
                setState(() => _selectedCategorySlug = slug);
                _scrollToKey(_menuSectionKey);
              },
              onSearch: (q) {
                setState(() => _searchQuery = q);
                _scrollToKey(_menuSectionKey);
              },
              scrollController: _scrollController,
            ),
          ),

          // Realtime Live Order Tracking Floating Banner (Consumer & Admin sync)
          const LiveOrderTrackerBanner(),
        ],
      ),

      // Floating Cart Pill (Mobile & Tablet)
      floatingActionButton: ListenableBuilder(
        listenable: CartManager.instance,
        builder: (context, _) {
          final count = CartManager.instance.totalItems;
          if (count == 0) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () => CartDrawer.show(context),
            backgroundColor: AppColors.caramel,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: const Icon(Icons.shopping_bag_outlined),
            label: Text(
              '$count Item • ${formatRupiah(CartManager.instance.grandTotal)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          );
        },
      ),
    );
  }
}
