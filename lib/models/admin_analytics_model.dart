// lib/models/admin_analytics_model.dart

class MenuItemPerformance {
  final String name;
  final String category;
  final int totalQuantity;
  final double totalRevenue;
  final double percentageOfSales;

  MenuItemPerformance({
    required this.name,
    required this.category,
    required this.totalQuantity,
    required this.totalRevenue,
    this.percentageOfSales = 0.0,
  });
}

class DailyRegistrationStat {
  final String dateKey; // Format: "18 Nov", "19 Nov", dst.
  final DateTime date;
  final int count;

  DailyRegistrationStat({
    required this.dateKey,
    required this.date,
    required this.count,
  });
}

class AdminAnalyticsSummary {
  final double totalRevenuePaid;
  final double totalRevenuePending;
  final int totalOrdersCount;
  final int totalPaidOrdersCount;
  final int totalDeliveredOrdersCount;
  final int totalCancelledOrdersCount;
  final double averageOrderValue;
  final int totalConsumersCount;
  final int newConsumersLast7Days;

  final List<DailyRegistrationStat> dailyRegistrations;
  final List<MenuItemPerformance> topSellingItems;
  final List<MenuItemPerformance> slowMovingItems;

  AdminAnalyticsSummary({
    required this.totalRevenuePaid,
    required this.totalRevenuePending,
    required this.totalOrdersCount,
    required this.totalPaidOrdersCount,
    required this.totalDeliveredOrdersCount,
    required this.totalCancelledOrdersCount,
    required this.averageOrderValue,
    required this.totalConsumersCount,
    required this.newConsumersLast7Days,
    required this.dailyRegistrations,
    required this.topSellingItems,
    required this.slowMovingItems,
  });
}
