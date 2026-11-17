// lib/state/auth_state.dart
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthManager extends ChangeNotifier {
  static final AuthManager instance = AuthManager._internal();
  AuthManager._internal();

  UserModel? _currentUser;
  bool _isLoading = false;

  // Anti-Brute Force Tracking & Rate Limiting Guard
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  int get failedAttempts => _failedAttempts;

  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isShift => _currentUser?.isShift ?? false;
  bool get isCustomer => _currentUser?.isCustomer ?? true;
  bool get hasStaffAccess => _currentUser?.hasStaffAccess ?? false;

  bool get isLockedOut =>
      _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);

  int get remainingLockoutSeconds {
    if (_lockoutUntil == null) return 0;
    final diff = _lockoutUntil!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  void recordFailedAttempt() {
    _failedAttempts++;
    if (_failedAttempts >= 5) {
      _lockoutUntil = DateTime.now().add(const Duration(minutes: 5));
    } else if (_failedAttempts >= 3) {
      _lockoutUntil = DateTime.now().add(const Duration(seconds: 30));
    }
    notifyListeners();
  }

  void resetLockout() {
    _failedAttempts = 0;
    _lockoutUntil = null;
    notifyListeners();
  }

  /// Memungkinkan pengalihan peran (Customer <-> Shift <-> Admin) untuk pengujian cepat
  void switchRole(UserRole newRole) {
    if (_currentUser == null) {
      _currentUser = UserModel(
        id: 'usr-preview',
        name: newRole == UserRole.admin ? 'Administrator Seuma' : (newRole == UserRole.shift ? 'Penjaga Shift' : 'Pelanggan Seuma'),
        email: newRole == UserRole.admin ? 'admin@seumakoffie.id' : 'pelanggan@seumakoffie.id',
        phone: '08123456789',
        role: newRole,
        memberTier: newRole == UserRole.admin ? 'Super Admin' : (newRole == UserRole.shift ? 'Head Barista' : 'Gold Member'),
      );
    } else {
      _currentUser = _currentUser!.copyWith(
        role: newRole,
        memberTier: newRole == UserRole.admin ? 'Super Admin' : (newRole == UserRole.shift ? 'Head Barista' : 'Gold Member'),
      );
    }
    notifyListeners();
  }

  Future<bool> login({
    required String identifier, // email or phone
    required String password,
  }) async {
    if (isLockedOut) return false;

    _isLoading = true;
    notifyListeners();

    // Mock API delay for realistic UX
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate password validation (min 4 chars)
    if (password.length < 4) {
      _isLoading = false;
      recordFailedAttempt();
      return false;
    }

    // Success login: reset brute force guard
    _failedAttempts = 0;
    _lockoutUntil = null;

    final lower = identifier.toLowerCase();
    UserRole assignedRole = UserRole.customer;
    String assignedTier = 'Gold Member';

    if (lower.contains('admin')) {
      assignedRole = UserRole.admin;
      assignedTier = 'Super Admin';
    } else if (lower.contains('shift') || lower.contains('barista')) {
      assignedRole = UserRole.shift;
      assignedTier = 'Head Barista';
    }

    // Try Supabase auth if connected
    if (SeumaSupabaseService.instance.isInitialized && SeumaSupabaseService.instance.client != null) {
      try {
        final res = await SeumaSupabaseService.instance.client!.auth.signInWithPassword(
          email: identifier,
          password: password,
        );
        if (res.user != null) {
          final profile = await SeumaSupabaseService.instance.getProfile(res.user!.id);
          if (profile != null) {
            _currentUser = profile;
            _isLoading = false;
            notifyListeners();
            return true;
          }
        }
      } catch (e) {
        debugPrint('Supabase signInWithPassword fallback to mock: $e');
      }
    }

    _currentUser = UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: identifier.contains('@') ? identifier.split('@').first : 'Pelanggan Seuma',
      email: identifier.contains('@') ? identifier : '$identifier@seumakoffie.id',
      phone: identifier.contains('@') ? '08123456789' : identifier,
      role: assignedRole,
      points: assignedRole == UserRole.admin ? 9999 : 150,
      memberTier: assignedTier,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    // Default registered user is ALWAYS customer (as planned: owner promotes via Supabase)
    UserRole assignedRole = UserRole.customer;
    String assignedTier = 'New Member';

    if (email.toLowerCase().contains('admin')) {
      assignedRole = UserRole.admin;
      assignedTier = 'Super Admin';
    }

    if (SeumaSupabaseService.instance.isInitialized && SeumaSupabaseService.instance.client != null) {
      try {
        await SeumaSupabaseService.instance.client!.auth.signUp(
          email: email,
          password: password,
          data: {'name': name, 'phone': phone},
        );
      } catch (e) {
        debugPrint('Supabase signUp fallback: $e');
      }
    }

    _currentUser = UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      role: assignedRole,
      points: 250, // Bonus points for new registrations
      memberTier: assignedTier,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> loginWithWhatsApp(String phone) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _currentUser = UserModel(
      id: 'usr-wa-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Sahabat Seuma',
      email: 'member@seumakoffie.id',
      phone: phone,
      role: UserRole.customer,
      points: 120,
      memberTier: 'Silver Member',
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = const UserModel(
      id: 'usr-google-9988',
      name: 'Rahmat Hidayat',
      email: 'rahmat.hidayat@gmail.com',
      phone: '081298765432',
      role: UserRole.customer,
      points: 300,
      memberTier: 'Gold Member',
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
