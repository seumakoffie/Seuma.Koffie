// lib/screens/home/widgets/notification_strip.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NotificationStrip extends StatelessWidget {
  const NotificationStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, size: 13, color: AppColors.gold),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Hadir di Kota Lhokseumawe & Sekitarnya • Buka Setiap Hari • Siap Antar 15-20 Mnt',
              style: TextStyle(
                color: AppColors.cream,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
