// lib/widgets/admin/admin_dashboard_dialog.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../state/admin_state.dart';
import '../../state/auth_state.dart';
import 'views/admin_consumer_tab.dart';
import 'views/admin_shift_keeper_tab.dart';
import 'views/admin_orders_management_tab.dart';
import 'views/blockchain_audit_view.dart';
import 'views/admin_menu_management_tab.dart';

class AdminDashboardDialog extends StatefulWidget {
  const AdminDashboardDialog({super.key});

  static Future<void> show(BuildContext context) {
    if (!AuthManager.instance.hasStaffAccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.espresso,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: AppColors.gold),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Akses Terbatas: Portal ini khusus untuk Administrator & Staf Shift Seuma.Koffie.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
      return Future.value();
    }

    AdminManager.instance.loadAllData();
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AdminDashboardDialog(),
    );
  }

  @override
  State<AdminDashboardDialog> createState() => _AdminDashboardDialogState();
}

class _AdminDashboardDialogState extends State<AdminDashboardDialog> with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthManager.instance;
    final admin = AdminManager.instance;
    final screenSize = MediaQuery.of(context).size;

    return ListenableBuilder(
      listenable: Listenable.merge([auth, admin]),
      builder: (context, _) {
        final currentUser = auth.currentUser;
        final currentRole = currentUser?.effectiveRole ?? UserRole.admin;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: const Color(0xFFFBF8F5),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Container(
            width: 1040,
            height: screenSize.height * 0.88,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo & Title
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: AppColors.espresso.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'lib/gambarlogo/logo_web.png',
                              width: 48,
                              height: 48,
                              cacheWidth: 144,
                              cacheHeight: 144,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Image.asset(
                                'lib/gambarlogo/logo.png',
                                width: 48,
                                height: 48,
                                cacheWidth: 144,
                                cacheHeight: 144,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: AppColors.espresso,
                                  child: const Center(child: Text('☕', style: TextStyle(fontSize: 24))),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Seuma.Koffie',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.espresso),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.caramel,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    currentRole == UserRole.admin ? 'ADMIN PORTAL' : 'SHIFT PORTAL',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Pusat Operasional: Konsumen, Penjaga Shift, & Verifikasi Pengantaran Lhokseumawe',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Controls & Role Quick Switcher (For Owner Testing)
                    Row(
                      children: [
                        // Role Switcher Dropdown (Simulator)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Text('Peran Aktif: ', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                              DropdownButton<UserRole>(
                                value: currentRole,
                                underline: const SizedBox(),
                                isDense: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: UserRole.admin,
                                    child: Text('👑 Admin (Full)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.espresso)),
                                  ),
                                  DropdownMenuItem(
                                    value: UserRole.shift,
                                    child: Text('⏱️ Penjaga Shift', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF00796B))),
                                  ),
                                  DropdownMenuItem(
                                    value: UserRole.customer,
                                    child: Text('👤 Konsumen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFE65100))),
                                  ),
                                ],
                                onChanged: (newRole) {
                                  if (newRole != null) {
                                    auth.switchRole(newRole);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Refresh Button
                        IconButton(
                          tooltip: 'Muat Ulang Data Supabase',
                          icon: const Icon(Icons.refresh, color: AppColors.espresso),
                          onPressed: () => admin.loadAllData(),
                        ),

                        // Close Dialog Button
                        IconButton(
                          tooltip: 'Tutup Dashboard',
                          icon: const Icon(Icons.close, color: AppColors.textMuted),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Navigation Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TabBar(
                    controller: _tabController,
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

                const SizedBox(height: 18),

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
