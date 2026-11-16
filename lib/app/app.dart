// lib/app/app.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

class SeumaKoffieApp extends StatelessWidget {
  const SeumaKoffieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seuma.Koffie — Authentic Artisanal Coffee & Brews',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppPages.onGenerateRoute,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        // Accessibility: Clamp textScaler between 0.85x and 1.25x to guarantee zero-clipping
        final clampedData = mediaQuery.copyWith(
          textScaler: mediaQuery.textScaler.clamp(
            minScaleFactor: 0.85,
            maxScaleFactor: 1.25,
          ),
        );
        return MediaQuery(
          data: clampedData,
          child: ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              scrollbars: false,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
