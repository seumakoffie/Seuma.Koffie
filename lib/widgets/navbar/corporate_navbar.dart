// lib/widgets/navbar/corporate_navbar.dart
// Modular Corporate Navbar Orchestrator for Seuma.Koffie v4.0
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'components/navbar_logo.dart';
import 'components/navbar_nav_link.dart';
import 'components/navbar_search_field.dart';
import 'components/navbar_auth_button.dart';
import 'components/navbar_cart_button.dart';
import 'components/navbar_order_button.dart';
import 'mobile/navbar_mobile_drawer.dart';
import 'mega_menu/mega_menu_container.dart';
import '../../state/auth_state.dart';
import '../admin/admin_dashboard_dialog.dart';

class CorporateNavbar extends StatefulWidget {
  final VoidCallback onOrderNow;
  final VoidCallback onExploreMenu;
  final VoidCallback onShowCart;
  final VoidCallback onShowAuth;
  final VoidCallback? onScrollToAbout;
  final VoidCallback? onScrollToPromo;
  final VoidCallback? onScrollToLocation;
  final VoidCallback? onScrollToTop;
  final ValueChanged<String>? onSelectCategory;
  final ValueChanged<String>? onSearch;
  final ScrollController? scrollController;

  const CorporateNavbar({
    super.key,
    required this.onOrderNow,
    required this.onExploreMenu,
    required this.onShowCart,
    required this.onShowAuth,
    this.onScrollToAbout,
    this.onScrollToPromo,
    this.onScrollToLocation,
    this.onScrollToTop,
    this.onSelectCategory,
    this.onSearch,
    this.scrollController,
  });

  @override
  State<CorporateNavbar> createState() => _CorporateNavbarState();
}

class _CorporateNavbarState extends State<CorporateNavbar>
    with TickerProviderStateMixin {
  bool _isScrolled = false;
  String? _openDropdown; // 'menu' | 'about' | 'promo' | 'location'
  late AnimationController _dropdownController;
  late Animation<double> _dropdownOpacity;
  late Animation<Offset> _dropdownSlide;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dropdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _dropdownOpacity = CurvedAnimation(
      parent: _dropdownController,
      curve: Curves.easeOut,
    );
    _dropdownSlide = Tween<Offset>(
      begin: const Offset(0, -0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _dropdownController, curve: Curves.easeOutCubic));

    widget.scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    if (_openDropdown != null) {
      _closeMenu();
    }
    final scrolled = (widget.scrollController?.offset ?? 0) > 40;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }
  }

  @override
  void dispose() {
    _dropdownController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openMenu(String key) {
    if (_openDropdown != key) {
      setState(() => _openDropdown = key);
      _dropdownController.forward(from: 0);
    }
  }

  void _closeMenu() {
    if (_openDropdown == null) return;
    _dropdownController.reverse().then((_) {
      if (mounted) setState(() => _openDropdown = null);
    });
  }

  void _toggleMenu(String key) {
    if (_openDropdown == key) {
      _closeMenu();
    } else {
      _openMenu(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 980;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Main Top Bar ─────────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _isScrolled
                ? const Color(0xFF130602).withValues(alpha: 0.96)
                : const Color(0xFF1A0A04).withValues(alpha: 0.90),
            border: Border(
              bottom: BorderSide(
                color: _isScrolled
                    ? AppColors.gold.withValues(alpha: 0.35)
                    : AppColors.gold.withValues(alpha: 0.20),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isScrolled ? 0.45 : 0.25),
                blurRadius: _isScrolled ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 64,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 36 : 16,
                ),
                child: isDesktop
                    ? _buildDesktopNav(context)
                    : _buildMobileNav(context),
              ),
            ),
          ),
        ),

        // ── Mega-Menu Dropdown Panel (Full Hit-Testable!) ──────────────────
        if (_openDropdown != null)
          SlideTransition(
            position: _dropdownSlide,
            child: FadeTransition(
              opacity: _dropdownOpacity,
              child: MegaMenuContainer(
                openDropdown: _openDropdown!,
                onSelectCategory: widget.onSelectCategory,
                onExploreMenu: widget.onExploreMenu,
                onOrderNow: widget.onOrderNow,
                onScrollToAbout: () => widget.onScrollToAbout?.call(),
                onScrollToPromo: () => widget.onScrollToPromo?.call(),
                onScrollToLocation: () => widget.onScrollToLocation?.call(),
                onClose: _closeMenu,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopNav(BuildContext context) {
    return Row(
      children: [
        NavbarLogo(onScrollToTop: widget.onScrollToTop),
        const SizedBox(width: 32),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NavbarNavLink(
              label: 'Menu',
              isOpen: _openDropdown == 'menu',
              onTap: () => _toggleMenu('menu'),
              onHover: () => _openMenu('menu'),
            ),
            NavbarNavLink(
              label: 'Tentang Kami',
              isOpen: _openDropdown == 'about',
              onTap: () => _toggleMenu('about'),
              onHover: () => _openMenu('about'),
            ),
            NavbarNavLink(
              label: 'Promo',
              isOpen: _openDropdown == 'promo',
              onTap: () => _toggleMenu('promo'),
              onHover: () => _openMenu('promo'),
            ),
            NavbarNavLink(
              label: 'Lokasi',
              isOpen: _openDropdown == 'location',
              onTap: () => _toggleMenu('location'),
              onHover: () => _openMenu('location'),
            ),
          ],
        ),
        const Spacer(),
        NavbarSearchField(
          controller: _searchController,
          onSearch: widget.onSearch,
          onTap: widget.onExploreMenu,
        ),
        const SizedBox(width: 14),
        ListenableBuilder(
          listenable: AuthManager.instance,
          builder: (context, _) {
            if (!AuthManager.instance.hasStaffAccess) return const SizedBox.shrink();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => AdminDashboardDialog.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFAA7C11)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AuthManager.instance.isAdmin ? Icons.admin_panel_settings : Icons.access_time_filled,
                          size: 15,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          AuthManager.instance.isAdmin ? 'Admin Portal' : 'Shift Board',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            );
          },
        ),
        NavbarAuthButton(onShowAuth: widget.onShowAuth),
        const SizedBox(width: 10),
        NavbarCartButton(onShowCart: widget.onShowCart),
        const SizedBox(width: 14),
        NavbarOrderButton(onOrderNow: widget.onOrderNow),
      ],
    );
  }

  Widget _buildMobileNav(BuildContext context) {
    return Row(
      children: [
        NavbarLogo(onScrollToTop: widget.onScrollToTop),
        const Spacer(),
        NavbarCartButton(onShowCart: widget.onShowCart),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            NavbarMobileDrawer.show(
              context,
              onExploreMenu: widget.onExploreMenu,
              onScrollToAbout: () => widget.onScrollToAbout?.call(),
              onScrollToPromo: () => widget.onScrollToPromo?.call(),
              onScrollToLocation: () => widget.onScrollToLocation?.call(),
              onOrderNow: widget.onOrderNow,
              onShowAuth: widget.onShowAuth,
              onScrollToTop: widget.onScrollToTop,
            );
          },
          icon: const Icon(Icons.menu_rounded, color: AppColors.cream, size: 26),
          tooltip: 'Menu Navigasi',
        ),
      ],
    );
  }
}
