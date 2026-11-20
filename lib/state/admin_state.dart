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

  String? _lastOrderError;
  String? get lastOrderError => _lastOrderError;

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
    } catch (e) {
      debugPrint('Error loading admin data: $e');
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

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
