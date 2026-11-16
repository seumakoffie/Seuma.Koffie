// lib/utils/responsive_layout.dart
// Responsive utility & breakpoint system for Seuma.Koffie
import 'package:flutter/material.dart';

class Breakpoints {
  Breakpoints._();

  /// Mobile compact/standard: < 600px (iPhone, Android phones)
  static const double mobile = 600;

  /// Tablet & iPad portrait: 600px - 960px
  static const double tablet = 960;

  /// Laptop & small desktop: 960px - 1280px
  static const double laptop = 1280;

  /// Large Desktop & Ultrawide: > 1280px
  static const double desktop = 1280;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= Breakpoints.mobile && w < Breakpoints.tablet;
  }

  static bool isLaptop(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= Breakpoints.tablet && w < Breakpoints.laptop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.laptop;

  /// Pick value dynamically based on screen width
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? laptop,
    required T desktop,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < Breakpoints.mobile) return mobile;
    if (w < Breakpoints.tablet) return tablet ?? mobile;
    if (w < Breakpoints.laptop) return laptop ?? tablet ?? desktop;
    return desktop;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.mobile) {
      return mobile;
    }
    if (width < Breakpoints.tablet) {
      return tablet ?? mobile;
    }
    return desktop;
  }
}
