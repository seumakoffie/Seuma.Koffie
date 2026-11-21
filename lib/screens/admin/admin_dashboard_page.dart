// lib/screens/admin/admin_dashboard_page.dart
// Dedicated Full-Page Admin & Shift Portal for Seuma.Koffie v6.0
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../state/auth_state.dart';
import '../../state/admin_state.dart';
import '../../models/user_model.dart';
import '../../app/routes/app_routes.dart';
import '../../widgets/admin/views/admin_consumer_tab.dart';
import '../../widgets/admin/views/admin_shift_keeper_tab.dart';
import '../../widgets/admin/views/admin_orders_management_tab.dart';
import '../../widgets/admin/views/admin_menu_management_tab.dart';
import '../../widgets/admin/views/blockchain_audit_view.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        AdminManager.instance.setSelectedTab(_tabController.index);
      }
    });
    // Muat data admin terbaru
    AdminManager.instance.loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openInNewTab() {
    final baseUrl = Uri.base.toString().split('#')[0];
    final fullUrl = '$baseUrl#/admin';
    launchUrl(Uri.parse(fullUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthManager.instance;
    final admin = AdminManager.instance;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 980;

    return ListenableBuilder(
      listenable: Listenable.merge([auth, admin]),
      builder: (context, _) {
        final currentUser = auth.currentUser;
        final currentRole = currentUser?.effectiveRole ?? UserRole.admin;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F4F0),
          appBar: AppBar(
            backgroundColor: AppColors.espresso,
            elevation: 3,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                // Tombol Kembali ke Toko
                OutlinedButton.icon(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.gold),
                  label: Text(
                    isDesktop ? '← Kembali ke Toko Konsumen' : 'Toko',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.gold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gold, width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 14),

                // Logo Brand Seuma
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'lib/gambarlogo/logo_web.png',
                      width: 34,
                      height: 34,
                      cacheWidth: 102,
                      cacheHeight: 102,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.caramel,
                        child: const Icon(Icons.coffee, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Judul Workspace
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Seuma.Koffie',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.caramel,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              currentRole == UserRole.admin ? 'ADMIN WORKSPACE' : 'SHIFT PORTAL',
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                      if (isDesktop)
                        const Text(
                          'Pusat Operasional Mandiri: Manajemen Pesanan, Shift, Menu & Forensik Blockchain Lhokseumawe',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Role Switcher Dropdown
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isDesktop ? 'Peran Aktif: ' : '',
                      style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    DropdownButton<UserRole>(
                      value: currentRole,
                      underline: const SizedBox(),
                      dropdownColor: AppColors.espresso,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold, size: 18),
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.gold),
                      items: const [
                        DropdownMenuItem(value: UserRole.admin, child: Text('👑 Admin (Full)')),
                        DropdownMenuItem(value: UserRole.shift, child: Text('☕ Penjaga Shift')),
                        DropdownMenuItem(value: UserRole.customer, child: Text('👤 Customer (Konsumen)')),
                      ],
                      onChanged: (newRole) {
                        if (newRole != null) auth.switchRole(newRole);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Tombol Buka Tab Baru
              IconButton(
                tooltip: 'Buka di Tab Baru Browser',
                icon: const Icon(Icons.open_in_new_rounded, color: AppColors.gold, size: 20),
                onPressed: _openInNewTab,
              ),

              // Tombol Refresh Data
              IconButton(
                tooltip: 'Refresh Data Realtime',
                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                onPressed: () => admin.loadAllData(),
              ),

              const SizedBox(width: 8),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 14, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Navigation Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: !isDesktop,
                    indicator: BoxDecoration(
                      color: AppColors.espresso,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textDark,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_alt_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text('Daftar Konsumen (${admin.consumers.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.badge_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text('Penjaga Shift (${admin.shiftKeepers.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text('Daftar Pesanan (${admin.orders.length})'),
                          ],
                        ),
                      ),
                      const Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Katalog Menu & Harga'),
                          ],
                        ),
                      ),
                      const Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_clock_outlined, size: 18),
                            SizedBox(width: 6),
                            Text('Blockchain & E2EE Ledger'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tab View Body
                Expanded(
                  child: admin.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.caramel),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: const [
                            AdminConsumerTab(),
                            AdminShiftKeeperTab(),
                            AdminOrdersManagementTab(),
                            AdminMenuManagementTab(),
                            BlockchainAuditView(),
                          ],
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
