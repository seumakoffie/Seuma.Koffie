// lib/state/admin_state.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/shift_schedule_model.dart';
import '../models/blockchain_block_model.dart';
import '../models/admin_analytics_model.dart';
import '../services/supabase_service.dart';
import '../services/sound_notification_service.dart';

class AdminManager extends ChangeNotifier {
  static final AdminManager instance = AdminManager._internal();
  AdminManager._internal();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _lastOrderError;
  String? get lastOrderError => _lastOrderError;

  String? _latestAlertMessage;
  String? get latestAlertMessage => _latestAlertMessage;

  void clearAlertMessage() {
    _latestAlertMessage = null;
    notifyListeners();
  }

  List<UserModel> _consumers = [];
  List<UserModel> get consumers => _consumers;

  List<UserModel> _shiftKeepers = [];
  List<UserModel> get shiftKeepers => _shiftKeepers;

  List<ShiftScheduleModel> _shiftSchedules = [];
  List<ShiftScheduleModel> get shiftSchedules => _shiftSchedules;

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  List<BlockchainBlockModel> _blockchainBlocks = [];
  List<BlockchainBlockModel> get blockchainBlocks => _blockchainBlocks;

  Map<String, dynamic> _blockchainStatus = {
    'isValid': true,
    'totalBlocks': 4,
    'message': 'Rantai Kriptografi 100% Valid & Terverifikasi',
  };
  Map<String, dynamic> get blockchainStatus => _blockchainStatus;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  OrderStatus? _orderFilter;
  OrderStatus? get orderFilter => _orderFilter;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  StreamSubscription<List<UserModel>>? _consumersSubscription;
  bool _isRealtimeConnected = false;
  bool get isRealtimeConnected => _isRealtimeConnected;

  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setOrderFilter(OrderStatus? filter) {
    _orderFilter = filter;
    notifyListeners();
  }

  List<OrderModel> get filteredOrders {
    if (_orderFilter == null) return _orders;
    return _orders.where((o) => o.status == _orderFilter).toList();
  }

  void startRealtimeOrdersListener() {
    _ordersSubscription?.cancel();
    _ordersSubscription = SeumaSupabaseService.instance.ordersStream.listen((liveOrders) {
      _orders = liveOrders;
      _isRealtimeConnected = true;
      notifyListeners();
    });
  }

  void startRealtimeConsumersListener() {
    _consumersSubscription?.cancel();
    _consumersSubscription = SeumaSupabaseService.instance.consumersStream.listen((liveConsumers) {
      _consumers = liveConsumers;
      notifyListeners();
    });
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final s = SeumaSupabaseService.instance;

      // 1. Ambil data konsumen terlebih dahulu secara instan
      s.fetchConsumers().then((res) {
        _consumers = res;
        _isLoading = false;
        notifyListeners();
      }).catchError((e) {
        debugPrint('Error loading consumers: $e');
        _isLoading = false;
        notifyListeners();
      });

      // 2. Ambil data lainnya secara paralel di background tanpa memblokir tab konsumen
      s.fetchShiftKeepers().then((res) { _shiftKeepers = res; notifyListeners(); }).catchError((_) {});
      s.fetchShiftSchedules().then((res) { _shiftSchedules = res; notifyListeners(); }).catchError((_) {});
      s.fetchOrders().then((res) { _orders = res; notifyListeners(); }).catchError((_) {});
      s.fetchBlockchainBlocks().then((res) { _blockchainBlocks = res; notifyListeners(); }).catchError((_) {});
      s.verifyBlockchainIntegrity().then((res) { _blockchainStatus = res; notifyListeners(); }).catchError((_) {});

      startRealtimeOrdersListener();
      startRealtimeConsumersListener();

      // 3. Daftarkan Realtime Channel Multi-Device (Postgres Changes)
      s.subscribeToRealtimeChanges(
        onOrdersUpdated: () {
          s.fetchOrders().then((live) {
            _orders = live;
            notifyListeners();
          }).catchError((_) {});
        },
        onBlockchainUpdated: () {
          s.fetchBlockchainBlocks().then((blocks) {
            _blockchainBlocks = blocks;
            notifyListeners();
          }).catchError((_) {});
          s.verifyBlockchainIntegrity().then((status) {
            _blockchainStatus = status;
            notifyListeners();
          }).catchError((_) {});
        },
        onNewOrderReceived: (orderData) {
          final orderNum = orderData['order_number']?.toString() ?? 'Baru';
          final amount = orderData['total_amount'] as int? ?? 0;
          SoundNotificationService.instance.playNewOrderAlert(orderNumber: orderNum, amount: amount);
          _latestAlertMessage = '🔔 Pesanan Baru Masuk: $orderNum (Rp $amount)';
          notifyListeners();
        },
        onNewCustomerRegistered: (profileData) {
          final name = profileData['name']?.toString() ?? profileData['email']?.toString() ?? 'Konsumen Baru';
          SoundNotificationService.instance.playNewCustomerAlert(customerName: name);
          _latestAlertMessage = '👤 Konsumen Baru Bergabung: $name';
          s.fetchConsumers().then((list) {
            _consumers = list;
            notifyListeners();
          }).catchError((_) {});
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error loading admin data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    final oldOrder = (index != -1) ? _orders[index] : null;

    // 1. Optimistic Local Update (0 ms instant UI reaction tanpa refresh)
    if (index != -1 && oldOrder != null) {
      _orders[index] = oldOrder.copyWith(status: newStatus);
      notifyListeners();
    }

    // 2. Kirim update ke database Supabase
    final success = await SeumaSupabaseService.instance.updateOrderStatus(orderId, newStatus);
    if (success) {
      // Refresh blockchain blocks di background agar selalu sinkron
      SeumaSupabaseService.instance.fetchBlockchainBlocks().then((blocks) {
        _blockchainBlocks = blocks;
        notifyListeners();
      }).catchError((_) {});
    } else {
      // Rollback jika terjadi kegagalan jaringan
      if (index != -1 && oldOrder != null) {
        _orders[index] = oldOrder;
        notifyListeners();
      }
    }
    return success;
  }

  Future<bool> updatePaymentStatus(String orderId, String newPaymentStatus) async {
    final success = await SeumaSupabaseService.instance.updatePaymentStatus(orderId, newPaymentStatus);
    if (success) {
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(paymentStatus: newPaymentStatus);
      }
      notifyListeners();
    }
    return success;
  }

  Future<bool> verifyDeliveryAtLocation({
    required String orderId,
    required String recipientName,
    required String verifiedByName,
    String? proofUrl,
    String? deliveryNotes,
  }) async {
    final success = await SeumaSupabaseService.instance.verifyDeliveryAtLocation(
      orderId: orderId,
      recipientName: recipientName,
      verifiedByName: verifiedByName,
      proofUrl: proofUrl,
      deliveryNotes: deliveryNotes,
    );

    if (success) {
      await loadAllData(); // Reload orders and blockchain blocks
    }
    return success;
  }

  Future<bool> addShiftSchedule(ShiftScheduleModel schedule) async {
    final success = await SeumaSupabaseService.instance.createShiftSchedule(schedule);
    if (success) {
      _shiftSchedules.insert(0, schedule);
      notifyListeners();
    }
    return success;
  }

  Future<bool> placeNewCustomerOrder(OrderModel order) async {
    _lastOrderError = null;
    final success = await SeumaSupabaseService.instance.placeCustomerOrder(order);
    if (success) {
      await loadAllData();
    } else {
      _lastOrderError = SeumaSupabaseService.instance.lastOrderError;
    }
    return success;
  }

  Future<void> auditBlockchainIntegrity() async {
    _blockchainStatus = await SeumaSupabaseService.instance.verifyBlockchainIntegrity();
    _blockchainBlocks = await SeumaSupabaseService.instance.fetchBlockchainBlocks();
    notifyListeners();
  }

  AdminAnalyticsSummary get analyticsSummary {
    double paidSum = 0.0;
    double pendingSum = 0.0;
    int paidCount = 0;
    int deliveredCount = 0;
    int cancelledCount = 0;

    final Map<String, int> menuQtyMap = {};
    final Map<String, double> menuRevMap = {};
    final Map<String, String> menuCatMap = {};

    for (final o in _orders) {
      final isPaid = o.paymentStatus.toLowerCase() == 'paid';
      if (isPaid) {
        paidSum += o.totalAmount;
        paidCount++;
      } else if (o.status != OrderStatus.cancelled) {
        pendingSum += o.totalAmount;
      }

      if (o.status == OrderStatus.delivered) {
        deliveredCount++;
      } else if (o.status == OrderStatus.cancelled) {
        cancelledCount++;
      }

      if (o.status != OrderStatus.cancelled) {
        for (final item in o.items) {
          final name = item.menuName;
          menuQtyMap[name] = (menuQtyMap[name] ?? 0) + item.quantity;
          menuRevMap[name] = (menuRevMap[name] ?? 0.0) + item.subtotal;
          menuCatMap[name] = item.variant ?? 'Kopi Aceh';
        }
      }
    }

    final double aov = paidCount > 0 ? (paidSum / paidCount) : 0.0;

    // Daily Registrations for Last 7 Days
    final now = DateTime.now();
    final List<DailyRegistrationStat> dailyRegs = [];
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

    int newLast7Days = 0;
    for (int i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final dateKey = '${targetDate.day} ${monthNames[targetDate.month - 1]}';
      int count = 0;

      for (final c in _consumers) {
        final ca = c.createdAt;
        if (ca != null &&
            ca.year == targetDate.year &&
            ca.month == targetDate.month &&
            ca.day == targetDate.day) {
          count++;
        }
      }
      newLast7Days += count;
      dailyRegs.add(DailyRegistrationStat(dateKey: dateKey, date: targetDate, count: count));
    }

    // Top Selling Items (Best Sellers)
    final allPerf = <MenuItemPerformance>[];
    int totalSoldAll = 0;
    menuQtyMap.forEach((_, q) => totalSoldAll += q);

    menuQtyMap.forEach((name, qty) {
      final rev = menuRevMap[name] ?? 0.0;
      final cat = menuCatMap[name] ?? 'Kopi Aceh';
      final pct = totalSoldAll > 0 ? (qty / totalSoldAll) * 100 : 0.0;
      allPerf.add(MenuItemPerformance(
        name: name,
        category: cat,
        totalQuantity: qty,
        totalRevenue: rev,
        percentageOfSales: pct,
      ));
    });

    allPerf.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
    final topSelling = allPerf.take(5).toList();

    // Slow moving items (Items in menu that have low or zero sales)
    final slowMoving = <MenuItemPerformance>[];
    final defaultMenus = [
      'Kopi Sanger Espresso',
      'Peach Americano (Iced)',
      'Sanger Arabica Dingin',
      'Espresso Romano',
      'Kopi Tubruk Gayo',
      'V60 Specialty Gayo',
      'Matcha Latte Sanger',
      'Cold Brew Sanger',
      'Caramel Macchiato Gayo'
    ];
    for (final dm in defaultMenus) {
      if (!menuQtyMap.containsKey(dm)) {
        slowMoving.add(MenuItemPerformance(
          name: dm,
          category: 'Kopi Aceh',
          totalQuantity: 0,
          totalRevenue: 0,
          percentageOfSales: 0.0,
        ));
      }
    }
    if (allPerf.length > 5) {
      slowMoving.addAll(allPerf.reversed.take(3));
    }

    return AdminAnalyticsSummary(
      totalRevenuePaid: paidSum,
      totalRevenuePending: pendingSum,
      totalOrdersCount: _orders.length,
      totalPaidOrdersCount: paidCount,
      totalDeliveredOrdersCount: deliveredCount,
      totalCancelledOrdersCount: cancelledCount,
      averageOrderValue: aov,
      totalConsumersCount: _consumers.length,
      newConsumersLast7Days: newLast7Days,
      dailyRegistrations: dailyRegs,
      topSellingItems: topSelling,
      slowMovingItems: slowMoving,
    );
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
