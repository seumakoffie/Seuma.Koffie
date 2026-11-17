// lib/state/admin_state.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/shift_schedule_model.dart';
import '../models/blockchain_block_model.dart';
import '../services/supabase_service.dart';

class AdminManager extends ChangeNotifier {
  static final AdminManager instance = AdminManager._internal();
  AdminManager._internal();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
      if (liveOrders.isNotEmpty) {
        _orders = liveOrders;
        _isRealtimeConnected = true;
        notifyListeners();
      }
    });
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final s = SeumaSupabaseService.instance;
      _consumers = await s.fetchConsumers();
      _shiftKeepers = await s.fetchShiftKeepers();
      _shiftSchedules = await s.fetchShiftSchedules();
      _orders = await s.fetchOrders();
      _blockchainBlocks = await s.fetchBlockchainBlocks();
      _blockchainStatus = await s.verifyBlockchainIntegrity();

      startRealtimeOrdersListener();
    } catch (e) {
      debugPrint('Error loading admin data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final success = await SeumaSupabaseService.instance.updateOrderStatus(orderId, newStatus);
    if (success) {
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
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
    final success = await SeumaSupabaseService.instance.placeCustomerOrder(order);
    if (success) {
      await loadAllData();
    }
    return success;
  }

  Future<void> auditBlockchainIntegrity() async {
    _blockchainStatus = await SeumaSupabaseService.instance.verifyBlockchainIntegrity();
    _blockchainBlocks = await SeumaSupabaseService.instance.fetchBlockchainBlocks();
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
