// lib/widgets/navbar/components/navbar_search_field.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NavbarSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onTap;

  const NavbarSearchField({
    super.key,
    required this.controller,
    this.onSearch,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 190,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25), width: 1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearch,
        onTap: onTap,
        style: const TextStyle(color: Colors.white, fontSize: 12.5),
        cursorColor: AppColors.gold,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Cari menu...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 12,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.gold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
      ),
    );
  }
}
