// lib/widgets/navbar/components/navbar_auth_button.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../state/auth_state.dart';
import '../../admin/admin_dashboard_dialog.dart';

class NavbarAuthButton extends StatelessWidget {
  final VoidCallback onShowAuth;

  const NavbarAuthButton({super.key, required this.onShowAuth});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthManager.instance,
      builder: (context, _) {
        final user = AuthManager.instance.currentUser;
        if (user != null) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: PopupMenuButton<String>(
              color: AppColors.espresso,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              offset: const Offset(0, 48),
              onSelected: (val) async {
                if (val == 'refresh_profile') {
                  await AuthManager.instance.refreshProfile();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Profil diperbarui: ${AuthManager.instance.currentUser?.effectiveRole.displayName ?? ""}'),
                        backgroundColor: Colors.green.shade700,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } else if (val == 'admin_portal') {
                  AdminDashboardDialog.show(context);
                } else if (val == 'revoke_other_devices') {
                  final count = await AuthManager.instance.revokeOtherDeviceSessions();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Berhasil mengeluarkan $count perangkat lain dari akun Anda.'),
                        backgroundColor: Colors.green.shade700,
                      ),
                    );
                  }
                } else if (val == 'logout') {
                  AuthManager.instance.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Anda telah keluar akun.')),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.caramel,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.effectiveRole.displayName,
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Text(user.email, style: const TextStyle(fontSize: 11, color: AppColors.cream)),
                    ],
                  ),
                ),
                if (user.hasStaffAccess) ...[
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'admin_portal',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings_outlined, size: 16, color: AppColors.gold),
                        SizedBox(width: 8),
                        Text('Buka Portal Admin & Shift', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
                if (AuthManager.instance.hasMultiDeviceAlert) ...[
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'revoke_other_devices',
                    child: Row(
                      children: [
                        const Icon(Icons.devices_other_rounded, size: 16, color: Colors.amberAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚠️ Terdeteksi ${AuthManager.instance.activeDeviceCount} Perangkat',
                                style: const TextStyle(color: Colors.amberAccent, fontSize: 11.5, fontWeight: FontWeight.w800),
                              ),
                              const Text(
                                'Klik untuk keluarkan perangkat lain',
                                style: TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'refresh_profile',
                  child: Row(
                    children: [
                      Icon(Icons.sync_rounded, size: 16, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text('Perbarui Profil', style: TextStyle(color: Colors.blueAccent, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, size: 16, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Keluar Akun', style: TextStyle(color: Colors.redAccent, fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: user.hasStaffAccess ? AppColors.caramel.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: user.hasStaffAccess ? AppColors.gold : AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (AuthManager.instance.hasMultiDeviceAlert) ...[
                      const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.amberAccent),
                      const SizedBox(width: 4),
                    ] else ...[
                      Icon(user.isAdmin ? Icons.shield_rounded : Icons.account_circle_rounded, size: 16, color: AppColors.gold),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      user.name.split(' ').first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 14, color: AppColors.gold),
                  ],
                ),
              ),
            ),
          );
        }
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onShowAuth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline_rounded, size: 15, color: AppColors.gold),
                  SizedBox(width: 6),
                  Text(
                    'Masuk / Daftar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
