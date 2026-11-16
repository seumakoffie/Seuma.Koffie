// lib/widgets/navbar/components/navbar_auth_button.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../state/auth_state.dart';

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
              onSelected: (val) {
                if (val == 'logout') {
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
                      Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13)),
                      Text(user.email, style: const TextStyle(fontSize: 11, color: AppColors.cream)),
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
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_circle_rounded, size: 16, color: AppColors.gold),
                    const SizedBox(width: 6),
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
