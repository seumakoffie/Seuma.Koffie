// lib/state/menu_state.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_item.dart';
import '../services/supabase_service.dart';
import 'auth_state.dart';

class MenuManager extends ChangeNotifier {
  static final MenuManager instance = MenuManager._internal();
  MenuManager._internal() {
    // Default in-memory cache menggunakan kMenuItems agar tidak blank screen
    _items = List<MenuItem>.from(kMenuItems);
  }

  List<MenuItem> _items = [];
  List<MenuItem> get items => List.unmodifiable(_items);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RealtimeChannel? _realtimeChannel;
  bool _isInitialized = false;

  /// Inisialisasi awal: Muat data dari Supabase & pasang listener Realtime
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await fetchLiveMenu();
    _subscribeToRealtime();
  }

  /// Ambil data menu terkini dari tabel Supabase `menu_items`
  Future<void> fetchLiveMenu() async {
    final client = SeumaSupabaseService.instance.client;
    if (client == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final liveItems = await SeumaSupabaseService.instance.fetchMenuItems();
      if (liveItems.isNotEmpty) {
        _items = liveItems;
      } else {
        // Jika database belum di-seed, database kosong: pertahankan kMenuItems
        debugPrint('Supabase menu_items kosong, menggunakan kMenuItems lokal default.');
      }
    } catch (e) {
      debugPrint('Error fetchLiveMenu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Berlangganan Realtime Postgres Changes ke tabel `menu_items`
  void _subscribeToRealtime() {
    final client = SeumaSupabaseService.instance.client;
    if (client == null) return;

    try {
      _realtimeChannel = client
          .channel('public:menu_items')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'menu_items',
            callback: (payload) {
              _handleRealtimePayload(payload);
            },
          )
          .subscribe();
      debugPrint('Realtime channel subscribed ke tabel public:menu_items');
    } catch (e) {
      debugPrint('Error subscribing realtime menu_items: $e');
    }
  }

  /// Menangani event INSERT / UPDATE / DELETE realtime
  void _handleRealtimePayload(PostgresChangePayload payload) {
    try {
      final eventType = payload.eventType;
      final newRecord = payload.newRecord;
      final oldRecord = payload.oldRecord;

      debugPrint('Realtime menu_items event: $eventType');

      if (eventType == PostgresChangeEvent.insert || eventType == PostgresChangeEvent.update) {
        if (newRecord.isNotEmpty) {
          final updatedItem = MenuItem.fromJson(newRecord);
          final index = _items.indexWhere((item) => item.id == updatedItem.id);

          if (index != -1) {
            _items[index] = updatedItem;
          } else {
            _items.add(updatedItem);
          }
          notifyListeners();
        }
      } else if (eventType == PostgresChangeEvent.delete) {
        if (oldRecord.isNotEmpty && oldRecord['id'] != null) {
          final deletedId = oldRecord['id'].toString();
          _items.removeWhere((item) => item.id == deletedId);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error handleRealtimePayload: $e');
    }
  }

  /// Ubah Harga Menu (KHUSUS SUPER ADMIN)
  Future<bool> updateMenuItemPrice({
    required String id,
    int? priceHot,
    int? priceIce,
    int? priceFixed,
  }) async {
    // Validasi otorisasi Super Admin
    if (!AuthManager.instance.isSuperAdmin) {
      debugPrint('Otorisasi Ditolak: Hanya Super Admin yang berhak mengubah harga menu.');
      return false;
    }

    final success = await SeumaSupabaseService.instance.updateMenuItemPrice(
      id: id,
      priceHot: priceHot,
      priceIce: priceIce,
      priceFixed: priceFixed,
    );

    if (success) {
      // Optimistic update lokal langsung
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(
          priceHot: priceHot,
          priceIce: priceIce,
          priceFixed: priceFixed,
        );
        notifyListeners();
      }
    }
    return success;
  }

  /// Ubah Ketersediaan Menu (Tersedia / Habis) (KHUSUS SUPER ADMIN)
  Future<bool> toggleAvailability({
    required String id,
    required bool isAvailable,
  }) async {
    if (!AuthManager.instance.isSuperAdmin) {
      debugPrint('Otorisasi Ditolak: Hanya Super Admin yang berhak mengubah status ketersediaan.');
      return false;
    }

    final success = await SeumaSupabaseService.instance.toggleMenuItemAvailability(
      id: id,
      isAvailable: isAvailable,
    );

    if (success) {
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(isAvailable: isAvailable);
        notifyListeners();
      }
    }
    return success;
  }

  /// Tambah atau Perbarui Item Menu (KHUSUS SUPER ADMIN)
  Future<bool> upsertMenuItem(MenuItem item, {int sortOrder = 0}) async {
    if (!AuthManager.instance.isSuperAdmin) {
      debugPrint('Otorisasi Ditolak: Hanya Super Admin yang berhak menambah/mengubah menu.');
      return false;
    }

    final success = await SeumaSupabaseService.instance.upsertMenuItem(item, sortOrder: sortOrder);
    if (success) {
      final index = _items.indexWhere((m) => m.id == item.id);
      if (index != -1) {
        _items[index] = item;
      } else {
        _items.add(item);
      }
      notifyListeners();
    }
    return success;
  }

  /// Hapus Item Menu (KHUSUS SUPER ADMIN)
  Future<bool> deleteMenuItem(String id) async {
    if (!AuthManager.instance.isSuperAdmin) {
      debugPrint('Otorisasi Ditolak: Hanya Super Admin yang berhak menghapus menu.');
      return false;
    }

    final success = await SeumaSupabaseService.instance.deleteMenuItem(id);
    if (success) {
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    }
    return success;
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }
}
