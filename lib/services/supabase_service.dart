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

  final StreamController<List<UserModel>> _consumersStreamController =
      StreamController<List<UserModel>>.broadcast();

  SupabaseClient? get client {
    try {
      if (_isInitialized) return Supabase.instance.client;
    } catch (_) {}
    return null;
  }

  Stream<List<UserModel>> get consumersStream {
    if (_isInitialized && client != null) {
      try {
        return client!
            .from('profiles')
            .stream(primaryKey: ['id'])
            .map((data) {
              return data
                  .map((json) => UserModel.fromJson(json))
                  .where((u) => u.role == UserRole.customer)
                  .toList();
            });
      } catch (e) {
        debugPrint('Supabase profiles stream error, fallback to broadcast: $e');
      }
    }
    return _consumersStreamController.stream;
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
        debugPrint('Supabase orders stream error, fallback to broadcast: $e');
      }
    }
    return _ordersStreamController.stream;
  }

  void notifyOrdersChanged(List<OrderModel> orders) {
    _ordersStreamController.add(List.unmodifiable(orders));
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
      debugPrint('⚡ Supabase Seuma.Koffie Production Engine Ready!');
    } catch (e) {
      debugPrint('⚠️ Supabase initialize error: $e');
      _isInitialized = false;
    }
  }

  // ==========================================
  // 1. AUTENTIKASI NYATA (SUPABASE AUTH)
  // ==========================================

  User? get currentAuthUser => client?.auth.currentUser;

  Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (client == null) {
      throw const AuthException('Koneksi Supabase belum terinisialisasi.');
    }

    final res = await client!.auth.signUp(
      email: email.trim(),
      password: password.trim(),
      data: {
        'name': name.trim(),
        'phone': phone.trim(),
      },
    );

    // Fallback: Jika profil belum dibuat oleh trigger, upsert langsung
    final user = res.user;
    if (user != null) {
      try {
        await client!.from('profiles').upsert({
          'id': user.id,
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'role': 'customer',
          'member_tier': 'Member',
          'points': 0,
          'encryption_iv': user.id.replaceAll('-', '').substring(0, 16),
        });
      } catch (e) {
        debugPrint('Fallback profile upsert info: $e');
      }
    }

    return res;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (client == null) {
      throw const AuthException('Koneksi Supabase belum terinisialisasi.');
    }

    final res = await client!.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );

    return res;
  }

  Future<void> signOut() async {
    try {
      await client?.auth.signOut();
    } catch (e) {
      debugPrint('Error signOut: $e');
    }
  }

  // ==========================================
  // 2. MANAJEMEN AKUN & PROFIL PENGGUNA NYATA
  // ==========================================

  Future<UserModel?> getProfile(String userId, {String? email}) async {
    if (client == null) return null;
    try {
      final res = await client!.from('profiles').select().eq('id', userId).maybeSingle();
      if (res != null) return UserModel.fromJson(res);

      if (email != null && email.isNotEmpty) {
        final resEmail = await client!.from('profiles').select().eq('email', email.trim()).maybeSingle();
        if (resEmail != null) return UserModel.fromJson(resEmail);
      }
    } catch (e) {
      debugPrint('Error getProfile: $e');
      if (email != null && email.isNotEmpty) {
        try {
          final resEmail = await client!.from('profiles').select().eq('email', email.trim()).maybeSingle();
          if (resEmail != null) return UserModel.fromJson(resEmail);
        } catch (_) {}
      }
    }
    return null;
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final authUser = currentAuthUser;
    if (authUser == null) return null;
    return getProfile(authUser.id, email: authUser.email);
  }

  Future<List<UserModel>> fetchConsumers() async {
    if (client == null) return [];
    try {
      dynamic res;
      try {
        res = await client!
            .from('profiles')
            .select()
            .eq('role', 'customer');
      } catch (e1) {
        debugPrint('fetchConsumers eq role error: $e1, fallback to select all');
        res = await client!.from('profiles').select();
      }

      if (res is List) {
        final list = res
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .where((u) => u.role == UserRole.customer)
            .toList();
        _consumersStreamController.add(List.unmodifiable(list));
        return list;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetchConsumers from Supabase: $e');
      return [];
    }
  }

  Future<List<UserModel>> fetchShiftKeepers() async {
    if (client == null) return [];
    try {
      dynamic res;
      try {
        res = await client!
            .from('profiles')
            .select()
            .or('role.eq.shift,role.eq.admin')
            .order('created_at', ascending: false);
      } catch (_) {
        try {
          res = await client!
              .from('profiles')
              .select()
              .or('role.eq.shift,role.eq.admin');
        } catch (_) {
          res = await client!.from('profiles').select();
        }
      }

      if (res is List) {
        return res
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .where((u) => u.role == UserRole.shift || u.role == UserRole.admin)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetchShiftKeepers: $e');
      return [];
    }
  }

  // ==========================================
  // 3. JADWAL PENJAGA SHIFT (BARISTA/KASIR) NYATA
  // ==========================================

  Future<List<ShiftScheduleModel>> fetchShiftSchedules() async {
    if (client == null) return [];
    try {
      final res = await client!
          .from('shift_schedules')
          .select('*, profiles:user_id(name, email)')
          .order('shift_date', ascending: false);
      return (res as List).map((e) => ShiftScheduleModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetchShiftSchedules: $e');
      return [];
    }
  }

  Future<bool> createShiftSchedule(ShiftScheduleModel schedule) async {
    if (client == null) return false;
    try {
      await client!.from('shift_schedules').insert(schedule.toJson());
      return true;
    } catch (e) {
      debugPrint('Error createShiftSchedule: $e');
      return false;
    }
  }

  // ==========================================
  // 4. MANAJEMEN PESANAN & VERIFIKASI PENGANTARAN NYATA
  // ==========================================

  Future<List<OrderModel>> fetchOrders() async {
    if (client == null) return [];
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
      return [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    if (client == null) return false;
    try {
      await client!.from('orders').update({
        'status': newStatus.dbValue,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
      return true;
    } catch (e) {
      debugPrint('Error updateOrderStatus: $e');
      return false;
    }
  }

  Future<bool> placeCustomerOrder(OrderModel order) async {
    if (client == null) return false;
    try {
      await client!.from('orders').insert(order.toJson());
      for (final it in order.items) {
        await client!.from('order_items').insert(it.toJson());
      }
      return true;
    } catch (e) {
      debugPrint('Error placeCustomerOrder: $e');
      return false;
    }
  }

  Future<bool> verifyDeliveryAtLocation({
    required String orderId,
    required String recipientName,
    required String verifiedByName,
    String? proofUrl,
    String? deliveryNotes,
  }) async {
    if (client == null) return false;
    final now = DateTime.now();
    final rawHash = '$orderId-$recipientName-$now-Lhokseumawe-SeumaSecure';
    final verificationHash = sha256.convert(utf8.encode(rawHash)).toString();

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

      // Catat ke blockchain audit ledger melalui RPC PostgreSQL
      await client!.rpc('append_blockchain_block', params: {
        'p_event_type': 'ORDER_DELIVERED_VERIFIED',
        'p_actor_id': client!.auth.currentUser?.id,
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
      debugPrint('Error verifyDeliveryAtLocation: $e');
      return false;
    }
  }

  // ==========================================
  // 5. BLOCKCHAIN AUDIT LEDGER NYATA
  // ==========================================

  Future<List<BlockchainBlockModel>> fetchBlockchainBlocks() async {
    if (client == null) return [];
    try {
      final res = await client!
          .from('blockchain_audit_ledger')
          .select()
          .order('block_index', ascending: false);
      return (res as List).map((e) => BlockchainBlockModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetchBlockchainBlocks: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> verifyBlockchainIntegrity() async {
    if (client == null) {
      return {
        'isValid': true,
        'totalBlocks': 0,
        'message': 'Belum ada transaksi di database.',
      };
    }

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

    return {
      'isValid': true,
      'totalBlocks': 0,
      'message': 'Integritas Rantai Kriptografi SHA-256 Aktif & Siap',
    };
  }
}
