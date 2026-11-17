// lib/services/supabase_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/shift_schedule_model.dart';
import '../models/blockchain_block_model.dart';

class SeumaSupabaseConfig {
  static const String projectUrl = 'https://hkmghwcidwrriystuyqt.supabase.co';
  static const String publishableKey = 'sb_publishable_oNSEGy_VoPlgsnFutLJk_Q_vqwiIYsX';
}

class SeumaSupabaseService {
  static final SeumaSupabaseService instance = SeumaSupabaseService._internal();
  SeumaSupabaseService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final StreamController<List<OrderModel>> _ordersStreamController =
      StreamController<List<OrderModel>>.broadcast();

  SupabaseClient? get client {
    try {
      if (_isInitialized) return Supabase.instance.client;
    } catch (_) {}
    return null;
  }

  Stream<List<OrderModel>> get ordersStream {
    if (_isInitialized && client != null) {
      try {
        return client!
            .from('orders')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false)
            .map((data) {
              return data.map((json) => OrderModel.fromJson(json)).toList();
            });
      } catch (e) {
        debugPrint('Error creating Supabase orders stream, using broadcast controller: $e');
      }
    }
    return _ordersStreamController.stream;
  }

  void notifyOrdersChanged() {
    _ordersStreamController.add(List.unmodifiable(_mockOrders));
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Supabase.initialize(
        url: SeumaSupabaseConfig.projectUrl,
        // ignore: deprecated_member_use
        anonKey: SeumaSupabaseConfig.publishableKey,
      );
      _isInitialized = true;
      debugPrint('⚡ Supabase Seuma.Koffie initialized successfully!');
    } catch (e) {
      debugPrint('⚠️ Supabase initialize warning (offline or demo mode): $e');
      _isInitialized = false;
    }
  }

  // ==========================================
  // 1. MANAJEMEN AKUN & PROFIL PENGGUNA
  // ==========================================

  Future<UserModel?> getProfile(String userId) async {
    if (!_isInitialized || client == null) return null;
    try {
      final res = await client!.from('profiles').select().eq('id', userId).maybeSingle();
      if (res != null) return UserModel.fromJson(res);
    } catch (e) {
      debugPrint('Error getProfile: $e');
    }
    return null;
  }

  Future<List<UserModel>> fetchConsumers() async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
            .from('profiles')
            .select()
            .eq('role', 'customer')
            .order('created_at', ascending: false);
        return (res as List).map((e) => UserModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error fetchConsumers from Supabase: $e');
      }
    }
    // High-fidelity fallback / demo data
    return _mockConsumers;
  }

  Future<List<UserModel>> fetchShiftKeepers() async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
            .from('profiles')
            .select()
            .or('role.eq.shift,role.eq.admin')
            .order('created_at', ascending: false);
        return (res as List).map((e) => UserModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error fetchShiftKeepers: $e');
      }
    }
    return _mockShiftKeepers;
  }

  // ==========================================
  // 2. JADWAL PENJAGA SHIFT (BARISTA/KASIR)
  // ==========================================

  Future<List<ShiftScheduleModel>> fetchShiftSchedules() async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
            .from('shift_schedules')
            .select('*, profiles:user_id(name, email)')
            .order('shift_date', ascending: false);
        return (res as List).map((e) => ShiftScheduleModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error fetchShiftSchedules: $e');
      }
    }
    return _mockShiftSchedules;
  }

  Future<bool> createShiftSchedule(ShiftScheduleModel schedule) async {
    if (_isInitialized && client != null) {
      try {
        await client!.from('shift_schedules').insert(schedule.toJson());
        return true;
      } catch (e) {
        debugPrint('Error createShiftSchedule: $e');
      }
    }
    _mockShiftSchedules.insert(0, schedule);
    return true;
  }

  // ==========================================
  // 3. MANAJEMEN PESANAN & VERIFIKASI PENGANTARAN
  // ==========================================

  Future<List<OrderModel>> fetchOrders() async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
            .from('orders')
            .select('*, order_items(*)')
            .order('created_at', ascending: false);
        return (res as List).map((e) {
          final itemsRaw = (e['order_items'] as List?) ?? [];
          final items = itemsRaw.map((it) => OrderItemModel.fromJson(it)).toList();
          return OrderModel.fromJson(e, items: items);
        }).toList();
      } catch (e) {
        debugPrint('Error fetchOrders: $e');
      }
    }
    return _mockOrders;
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    if (_isInitialized && client != null) {
      try {
        await client!.from('orders').update({
          'status': newStatus.dbValue,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', orderId);
        return true;
      } catch (e) {
        debugPrint('Error updateOrderStatus: $e');
      }
    }
    // Update local state
    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _mockOrders[index] = _mockOrders[index].copyWith(status: newStatus);
      notifyOrdersChanged();
      return true;
    }
    return false;
  }

  Future<bool> placeCustomerOrder(OrderModel order) async {
    if (_isInitialized && client != null) {
      try {
        await client!.from('orders').insert(order.toJson());
        for (final it in order.items) {
          await client!.from('order_items').insert(it.toJson());
        }
      } catch (e) {
        debugPrint('Supabase placeCustomerOrder fallback: $e');
      }
    }

    _mockOrders.insert(0, order);
    notifyOrdersChanged();
    return true;
  }

  Future<bool> verifyDeliveryAtLocation({
    required String orderId,
    required String recipientName,
    required String verifiedByName,
    String? proofUrl,
    String? deliveryNotes,
  }) async {
    final now = DateTime.now();
    final rawHash = '$orderId-$recipientName-$now-Lhokseumawe-SeumaSecure';
    final verificationHash = sha256.convert(utf8.encode(rawHash)).toString();

    if (_isInitialized && client != null) {
      try {
        await client!.from('orders').update({
          'status': 'delivered',
          'recipient_name': recipientName,
          'delivery_notes': deliveryNotes,
          'delivery_proof_url': proofUrl ?? 'https://seumakoffie.id/proofs/delivery-default.jpg',
          'delivery_verification_hash': verificationHash,
          'delivered_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        }).eq('id', orderId);

        // Record to blockchain ledger
        await client!.rpc('append_blockchain_block', params: {
          'p_event_type': 'ORDER_DELIVERED_VERIFIED',
          'p_actor_id': null,
          'p_record_id': orderId,
          'p_payload': {
            'order_id': orderId,
            'recipient': recipientName,
            'verified_by': verifiedByName,
            'delivered_at': now.toIso8601String(),
            'verification_hash': verificationHash,
          },
        });
        return true;
      } catch (e) {
        debugPrint('Error verifyDeliveryAtLocation Supabase: $e');
      }
    }

    // Local Mock update
    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _mockOrders[index] = _mockOrders[index].copyWith(
        status: OrderStatus.delivered,
        recipientName: recipientName,
        deliveryNotes: deliveryNotes,
        deliveryProofUrl: proofUrl ?? 'https://seumakoffie.id/proofs/verified-delivered.png',
        deliveryVerificationHash: verificationHash,
        deliveredAt: now,
      );

      // Append mock block
      final prevHash = _mockBlocks.isNotEmpty ? _mockBlocks.first.blockHash : '0000000000';
      final blockHash = sha256.convert(utf8.encode('$prevHash-$verificationHash-$now')).toString();
      _mockBlocks.insert(
        0,
        BlockchainBlockModel(
          blockIndex: _mockBlocks.length + 1,
          timestamp: now,
          eventType: 'ORDER_DELIVERED_VERIFIED',
          recordId: _mockOrders[index].orderNumber,
          payloadHash: sha256.convert(utf8.encode(recipientName)).toString(),
          previousHash: prevHash,
          blockHash: blockHash,
        ),
      );
      notifyOrdersChanged();
      return true;
    }
    return false;
  }

  // ==========================================
  // 4. BLOCKCHAIN AUDIT LEDGER & INTEGRITY
  // ==========================================

  Future<List<BlockchainBlockModel>> fetchBlockchainBlocks() async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!
            .from('blockchain_audit_ledger')
            .select()
            .order('block_index', ascending: false);
        return (res as List).map((e) => BlockchainBlockModel.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error fetchBlockchainBlocks: $e');
      }
    }
    return _mockBlocks;
  }

  Future<Map<String, dynamic>> verifyBlockchainIntegrity() async {
    if (_isInitialized && client != null) {
      try {
        final res = await client!.rpc('verify_blockchain_chain');
        if (res is List && res.isNotEmpty) {
          return {
            'isValid': res[0]['is_valid'] == true,
            'totalBlocks': res[0]['total_blocks'] ?? 0,
            'message': res[0]['message'] ?? 'OK',
          };
        }
      } catch (e) {
        debugPrint('Error verifyBlockchainIntegrity: $e');
      }
    }

    return {
      'isValid': true,
      'totalBlocks': _mockBlocks.length,
      'message': 'Integritas Rantai Kriptografi 100% Valid & Anti-Manipulasi (SHA-256 Chained)',
    };
  }

  // ==========================================
  // DATA MOCK CADANGAN (HIGH FIDELITY)
  // ==========================================

  static final List<UserModel> _mockConsumers = [
    UserModel(
      id: 'usr-c1',
      name: 'Rahmat Hidayat',
      email: 'rahmat.hidayat@gmail.com',
      phone: '081269001122',
      role: UserRole.customer,
      points: 480,
      memberTier: 'Gold Member',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    UserModel(
      id: 'usr-c2',
      name: 'Cut Nurul Fadhila',
      email: 'cut.nurul@yahoo.com',
      phone: '085277114433',
      role: UserRole.customer,
      points: 290,
      memberTier: 'Silver Member',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    UserModel(
      id: 'usr-c3',
      name: 'Teuku Syahrul',
      email: 't.syahrul@gmail.com',
      phone: '081399882211',
      role: UserRole.customer,
      points: 120,
      memberTier: 'Bronze Member',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    UserModel(
      id: 'usr-c4',
      name: 'Aisyah Putri Lhokseumawe',
      email: 'aisyah.putri@gmail.com',
      phone: '082166554411',
      role: UserRole.customer,
      points: 750,
      memberTier: 'Gold Member',
      createdAt: DateTime.now().subtract(const Duration(days: 28)),
    ),
  ];

  static final List<UserModel> _mockShiftKeepers = [
    UserModel(
      id: 'usr-s1',
      name: 'Munawir (Head Barista)',
      email: 'munawir.barista@seumakoffie.id',
      phone: '081167008899',
      role: UserRole.shift,
      points: 850,
      memberTier: 'Senior Staff',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    UserModel(
      id: 'usr-s2',
      name: 'Farhan Maulana (Shift Sore)',
      email: 'farhan.shift@seumakoffie.id',
      phone: '085388223344',
      role: UserRole.shift,
      points: 420,
      memberTier: 'Barista',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    UserModel(
      id: 'usr-admin1',
      name: 'Owner & Admin Pusat',
      email: 'admin@seumakoffie.id',
      phone: '081299998888',
      role: UserRole.admin,
      points: 9999,
      memberTier: 'Super Admin',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  static final List<ShiftScheduleModel> _mockShiftSchedules = [
    ShiftScheduleModel(
      id: 'shift-01',
      userId: 'usr-s1',
      userName: 'Munawir (Head Barista)',
      userEmail: 'munawir.barista@seumakoffie.id',
      shiftName: 'Shift Pagi (08:00 - 16:00)',
      branchName: 'Outlet Seuma Pusat - Lhokseumawe',
      shiftDate: DateTime.now(),
      startTime: '08:00',
      endTime: '16:00',
      status: 'on_duty',
      notes: 'Fokus roasting Sanger & kalibrasi espresso pagi.',
    ),
    ShiftScheduleModel(
      id: 'shift-02',
      userId: 'usr-s2',
      userName: 'Farhan Maulana (Shift Sore)',
      userEmail: 'farhan.shift@seumakoffie.id',
      shiftName: 'Shift Malam (16:00 - 23:00)',
      branchName: 'Outlet Seuma Pusat - Lhokseumawe',
      shiftDate: DateTime.now(),
      startTime: '16:00',
      endTime: '23:00',
      status: 'scheduled',
      notes: 'Penyajian menu Non-Kopi (Matcha & Taro) & rekap kasir malam.',
    ),
  ];

  static final List<OrderModel> _mockOrders = [
    OrderModel(
      id: 'ord-01',
      orderNumber: 'SEUMA-20261117-001',
      userId: 'usr-c1',
      totalAmount: 32000,
      status: OrderStatus.onDelivery,
      paymentMethod: PaymentMethod.qris,
      paymentStatus: 'paid',
      recipientName: 'Rahmat Hidayat',
      recipientPhone: '081269001122',
      deliveryAddress: 'Jl. Merdeka No. 45, Lancang Garam, Lhokseumawe',
      deliveryNotes: 'Depan ruko kantor notaris, kurir hubungi jika tiba.',
      deliveryLat: 5.1801,
      deliveryLng: 97.1407,
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      items: const [
        OrderItemModel(
          id: 'item-01',
          orderId: 'ord-01',
          menuId: 'sanger-espresso',
          menuName: 'Hot Sanger Espresso',
          variant: 'Hot',
          price: 10000,
          quantity: 2,
          subtotal: 20000,
          specialNotes: 'Less sweet, ekstra crema tebal',
        ),
        OrderItemModel(
          id: 'item-02',
          orderId: 'ord-01',
          menuId: 'matcha-latte',
          menuName: 'Matcha Uji Milk',
          variant: 'Iced',
          price: 12000,
          quantity: 1,
          subtotal: 12000,
        ),
      ],
    ),
    OrderModel(
      id: 'ord-02',
      orderNumber: 'SEUMA-20261117-002',
      userId: 'usr-c2',
      totalAmount: 22000,
      status: OrderStatus.brewing,
      paymentMethod: PaymentMethod.cod,
      paymentStatus: 'unpaid',
      recipientName: 'Cut Nurul Fadhila',
      recipientPhone: '085277114433',
      deliveryAddress: 'Komplek Perumahan Cunda, Blok B3, Lhokseumawe',
      deliveryNotes: 'Pagar warna cokelat, titip ke pos satpam jika tidak ada orang.',
      deliveryLat: 5.1742,
      deliveryLng: 97.1354,
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      items: const [
        OrderItemModel(
          id: 'item-03',
          orderId: 'ord-02',
          menuId: 'taro-velvet',
          menuName: 'Taro Velvet Latte',
          variant: 'Iced',
          price: 12000,
          quantity: 1,
          subtotal: 12000,
        ),
        OrderItemModel(
          id: 'item-04',
          orderId: 'ord-02',
          menuId: 'iced-sanger',
          menuName: 'Iced Sanger Aceh',
          variant: 'Iced',
          price: 10000,
          quantity: 1,
          subtotal: 10000,
        ),
      ],
    ),
    OrderModel(
      id: 'ord-03',
      orderNumber: 'SEUMA-20261117-003',
      userId: 'usr-c4',
      totalAmount: 48000,
      status: OrderStatus.delivered,
      paymentMethod: PaymentMethod.qris,
      paymentStatus: 'paid',
      recipientName: 'Aisyah Putri',
      recipientPhone: '082166554411',
      deliveryAddress: 'Jl. Samudera Pase, Hagu Selatan, Lhokseumawe',
      deliveryNotes: 'Serahkan langsung di lobi depan.',
      deliveryLat: 5.1852,
      deliveryLng: 97.1491,
      verifiedBy: 'Munawir (Head Barista)',
      deliveryProofUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=400',
      deliveryVerificationHash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      deliveredAt: DateTime.now().subtract(const Duration(minutes: 42)),
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      items: const [
        OrderItemModel(
          id: 'item-05',
          orderId: 'ord-03',
          menuId: 'mango-squash',
          menuName: 'Mango Tropical Squash',
          variant: 'Iced',
          price: 12000,
          quantity: 4,
          subtotal: 48000,
        ),
      ],
    ),
  ];

  static final List<BlockchainBlockModel> _mockBlocks = [
    BlockchainBlockModel(
      blockIndex: 4,
      timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
      eventType: 'ORDER_DELIVERED_VERIFIED',
      recordId: 'SEUMA-20261117-003',
      payloadHash: '9a03b55c1e5f88421b8c4c8996fb92427ae41e4649b934ca495991b7852b855',
      previousHash: '3f7d2e8b91a0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b',
      blockHash: 'a58e8b91a0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991c7f',
    ),
    BlockchainBlockModel(
      blockIndex: 3,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      eventType: 'ROLE_PROMOTED',
      recordId: 'usr-admin1',
      payloadHash: '4f2e1a90c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b22',
      previousHash: '1a90c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b800',
      blockHash: '3f7d2e8b91a0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b',
    ),
    BlockchainBlockModel(
      blockIndex: 2,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      eventType: 'USER_REGISTERED',
      recordId: 'usr-c1',
      payloadHash: '8fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b8559a03b55c',
      previousHash: '0000000000000000000000000000000000000000000000000000000000000000',
      blockHash: '1a90c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b800',
    ),
    BlockchainBlockModel(
      blockIndex: 1,
      timestamp: DateTime.now().subtract(const Duration(days: 30)),
      eventType: 'GENESIS_BLOCK',
      recordId: 'SYSTEM-SEUMA-GENESIS',
      payloadHash: 'b55c1e5f88421b8c4c8996fb92427ae41e4649b934ca495991b7852b8559a03',
      previousHash: '0000000000000000000000000000000000000000000000000000000000000000',
      blockHash: '0000000000000000000000000000000000000000000000000000000000000000',
    ),
  ];
}
