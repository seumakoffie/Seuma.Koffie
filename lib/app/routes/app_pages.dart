// lib/app/routes/app_pages.dart
import 'package:flutter/material.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/admin/admin_dashboard_page.dart';
import 'app_routes.dart';

class AppPages {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.admin:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminDashboardPage(),
        );
      case AppRoutes.home:
      case AppRoutes.menu:
      case AppRoutes.about:
      case AppRoutes.promo:
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
    }
  }
}
