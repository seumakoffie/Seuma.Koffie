// lib/widgets/admin/components/analytics_chart_painter.dart
import 'package:flutter/material.dart';
import '../../../models/admin_analytics_model.dart';
import '../../../theme/app_theme.dart';

class RegistrationTrafficBarChart extends StatelessWidget {
  final List<DailyRegistrationStat> stats;
  final double height;

  const RegistrationTrafficBarChart({
    super.key,
    required this.stats,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('Belum ada data trafik pendaftaran.', style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    int maxCount = 1;
    for (final s in stats) {
      if (s.count > maxCount) maxCount = s.count;
    }

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: stats.map((s) {
          final double barHeightRatio = (s.count / maxCount).clamp(0.08, 1.0);
          final bool isToday = s.date.day == DateTime.now().day;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Label Jumlah Akun
                  Text(
                    '${s.count}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                      color: isToday ? const Color(0xFFE65100) : AppColors.espresso,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Batang Grafik Bergradien
                  Flexible(
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        final double barHeight = (constraints.maxHeight * barHeightRatio).clamp(12.0, constraints.maxHeight);
                        return Container(
                          height: barHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isToday
                                  ? [const Color(0xFFFF9800), const Color(0xFFE65100)]
                                  : [const Color(0xFFD4AF37), const Color(0xFF2A1810)],
                            ),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            boxShadow: [
                              BoxShadow(
                                color: (isToday ? const Color(0xFFE65100) : AppColors.espresso).withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Label Tanggal
                  Text(
                    s.dateKey,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                      color: isToday ? const Color(0xFFE65100) : AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
