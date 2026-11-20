// lib/state/auth_state.dart
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop' show JS;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

/// Ambil atau buat fingerprint permanen di localStorage browser
String _getOrCreateDeviceFingerprint() {
  if (!kIsWeb) {
    return 'seuma-native-device';
  }
  try {
    final existing = _localStorageGet('seuma_device_fp');
    if (existing != null && existing.isNotEmpty) return existing;
    final newFp = 'seuma-web-${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
    _localStorageSet('seuma_device_fp', newFp);
    return newFp;
  } catch (_) {
    return 'seuma-web-fallback';
  }
}

@JS('window.localStorage.getItem')
external String? _localStorageGet(String key);

@JS('window.localStorage.setItem')
external void _localStorageSet(String key, String value);

class AuthManager extends ChangeNotifier {
  static final AuthManager instance = AuthManager._internal();
  AuthManager._internal() {
    _initAuthListener();
  }

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isRememberMe = true;

  // Pelacakan Perangkat & Multi-Device Alert
  final String _currentDeviceFingerprint = _getOrCreateDeviceFingerprint();
  List<Map<String, dynamic>> _activeDeviceSessions = [];
  StreamSubscription<List<Map<String, dynamic>>>? _deviceSessionSub;

  // Anti-Brute Force Tracking & Rate Limiting Guard
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isRememberMe => _isRememberMe;
  int get failedAttempts => _failedAttempts;

  List<Map<String, dynamic>> get activeDeviceSessions => _activeDeviceSessions;
  bool get hasMultiDeviceAlert => _activeDeviceSessions.length > 1;
  int get activeDeviceCount => _activeDeviceSessions.isEmpty ? 1 : _activeDeviceSessions.length;
  String get currentDeviceFingerprint => _currentDeviceFingerprint;

  void setRememberMe(bool val) {
    _isRememberMe = val;
    notifyListeners();
  }

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

  void _initAuthListener() {
    try {
      final client = SeumaSupabaseService.instance.client;
      if (client == null) return;

      // Cek sesi yang sudah tersimpan saat web dibuka
      final currentSession = client.auth.currentSession;
      if (currentSession != null) {
        _fetchAndSetProfile(currentSession.user.id, email: currentSession.user.email);
      }

      // Dengarkan perubahan login / logout secara realtime
      client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          _fetchAndSetProfile(session.user.id, email: session.user.email);
        } else {
          _currentUser = null;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Error initAuthListener: $e');
    }
  }

  Future<void> _fetchAndSetProfile(String userId, {String? email}) async {
    try {
      final authUser = SeumaSupabaseService.instance.currentAuthUser;
      final effectiveEmail = email ?? authUser?.email;
      final profile = await SeumaSupabaseService.instance.getProfile(userId, email: effectiveEmail);
      final isOwner = UserModel.isSuperAdminEmail(profile?.email ?? effectiveEmail);

      if (profile != null) {
        if ((isOwner || profile.role == UserRole.admin) && profile.role != UserRole.admin) {
          _currentUser = profile.copyWith(role: UserRole.admin, memberTier: 'Super Admin');
        } else {
          _currentUser = profile;
        }
      } else if (isOwner) {
        _currentUser = UserModel(
          id: userId,
          name: authUser?.userMetadata?['name']?.toString() ?? (effectiveEmail?.split('@').first ?? 'Admin Seuma'),
          email: effectiveEmail ?? '',
          phone: '',
          role: UserRole.admin,
          memberTier: 'Super Admin',
        );
      }

      // Daftarkan sesi perangkat dan dengarkan status multi-perangkat
      _initDeviceTracking(userId);

      notifyListeners();
    } catch (e) {
      debugPrint('Error _fetchAndSetProfile: $e');
    }
  }

  void _initDeviceTracking(String userId) {
    try {
      final s = SeumaSupabaseService.instance;
      s.registerDeviceSession(
        userId: userId,
        deviceFingerprint: _currentDeviceFingerprint,
        deviceName: kIsWeb ? 'Web Browser (Perangkat Ini)' : 'Aplikasi Seuma.Koffie',
      );

      _deviceSessionSub?.cancel();
      _deviceSessionSub = s.deviceSessionsStream(userId).listen((sessions) {
        _activeDeviceSessions = sessions;
        notifyListeners();
      });

      // Muat awal daftar perangkat aktif
      s.getActiveDeviceSessions(userId).then((list) {
        if (list.isNotEmpty) {
          _activeDeviceSessions = list;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Error initDeviceTracking: $e');
    }
  }

  Future<bool> revokeOtherDeviceSessions() async {
    final user = _currentUser;
    if (user == null) return false;
    final success = await SeumaSupabaseService.instance.revokeOtherDeviceSessions(
      userId: user.id,
      currentFingerprint: _currentDeviceFingerprint,
    );
    if (success) {
      _activeDeviceSessions = _activeDeviceSessions
          .where((s) => s['device_fingerprint'] == _currentDeviceFingerprint)
          .toList();
      notifyListeners();
    }
    return success;
  }

  /// Reset Password menggunakan On-Screen OTP tanpa perlu email
  Future<String?> resetPasswordWithOnScreenOtp({
    required String email,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final exists = await SeumaSupabaseService.instance.checkEmailExists(email);
      if (!exists) {
        _isLoading = false;
        notifyListeners();
        return 'Email tidak ditemukan dalam sistem Seuma.Koffie.';
      }

      final success = await SeumaSupabaseService.instance.resetUserPasswordDirectly(
        email: email,
        newPassword: newPassword,
      );

      if (success) {
        // Otomatis login dengan password baru
        final loginErr = await login(identifier: email, password: newPassword);
        _isLoading = false;
        notifyListeners();
        return loginErr; // null jika sukses login
      } else {
        _isLoading = false;
        notifyListeners();
        return 'Gagal memperbarui kata sandi. Silakan coba lagi.';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Terjadi kendala reset kata sandi: $e';
    }
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

  /// Memungkinkan pengalihan peran untuk pengujian tampilan
  void switchRole(UserRole newRole) {
    if (_currentUser == null) {
      _currentUser = UserModel(
        id: 'usr-preview',
        name: newRole == UserRole.admin ? 'Administrator Seuma' : (newRole == UserRole.shift ? 'Penjaga Shift' : 'Pelanggan Seuma'),
        email: newRole == UserRole.admin ? 'admin@seumakoffie.id' : 'pelanggan@seumakoffie.id',
        phone: '08123456789',
        role: newRole,
        memberTier: newRole == UserRole.admin ? 'Super Admin' : (newRole == UserRole.shift ? 'Head Barista' : 'Member'),
      );
    } else {
      _currentUser = _currentUser!.copyWith(
        role: newRole,
        memberTier: newRole == UserRole.admin ? 'Super Admin' : (newRole == UserRole.shift ? 'Head Barista' : 'Member'),
      );
    }
    notifyListeners();
  }

  /// LOGIN NYATA KE SUPABASE AUTH (Mengembalikan null jika sukses, atau pesan error jika gagal)
  Future<String?> login({
    required String identifier, // email
    required String password,
  }) async {
    if (isLockedOut) {
      return 'Akses ditangguhkan sementara (Anti-Brute Force). Tunggu $remainingLockoutSeconds detik.';
    }

    _isLoading = true;
    notifyListeners();

    try {
      final res = await SeumaSupabaseService.instance.signIn(
        email: identifier.trim(),
        password: password.trim(),
      );

      final user = res.user;
      if (user != null) {
        // Reset brute force
        _failedAttempts = 0;
        _lockoutUntil = null;

        // Ambil profil nyata dari database profiles
        UserModel? profile = await SeumaSupabaseService.instance.getProfile(user.id, email: user.email);
        
        // Jika profil belum terambil sesaat setelah trigger
        if (profile == null) {
          await Future.delayed(const Duration(milliseconds: 400));
          profile = await SeumaSupabaseService.instance.getProfile(user.id, email: user.email);
        }

        final isOwner = UserModel.isSuperAdminEmail(user.email ?? identifier);
        final resolvedRole = (isOwner || profile?.role == UserRole.admin) ? UserRole.admin : (profile?.role ?? UserRole.customer);
        final resolvedTier = (isOwner || profile?.role == UserRole.admin) ? (profile?.memberTier.isNotEmpty == true && profile?.memberTier != 'Member' && profile?.memberTier != 'New Member' ? profile!.memberTier : 'Super Admin') : (profile?.memberTier ?? 'Member');

        _currentUser = profile?.copyWith(role: resolvedRole, memberTier: resolvedTier) ?? UserModel(
          id: user.id,
          name: user.userMetadata?['name']?.toString() ?? user.email?.split('@').first ?? 'Pelanggan',
          email: user.email ?? identifier,
          phone: user.userMetadata?['phone']?.toString() ?? '',
          role: resolvedRole,
          memberTier: resolvedTier,
        );

        _isLoading = false;
        notifyListeners();
        return null; // Sukses
      } else {
        recordFailedAttempt();
        _isLoading = false;
        notifyListeners();
        return 'Email atau kata sandi tidak ditemukan.';
      }
    } on AuthException catch (e) {
      recordFailedAttempt();
      _isLoading = false;
      notifyListeners();
      return _translateAuthError(e.message);
    } catch (e) {
      recordFailedAttempt();
      _isLoading = false;
      notifyListeners();
      return 'Gagal menghubungkan ke database: $e';
    }
  }

  /// REGISTRASI NYATA KE SUPABASE AUTH (Mengembalikan null jika sukses, atau pesan error jika gagal)
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await SeumaSupabaseService.instance.signUp(
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        password: password.trim(),
      );

      final user = res.user;
      if (user != null) {
        // Berikan waktu sejenak agar trigger on_auth_user_created selesai membuat profil
        await Future.delayed(const Duration(milliseconds: 500));
        
        UserModel? profile = await SeumaSupabaseService.instance.getProfile(user.id);
        
        _currentUser = profile ?? UserModel(
          id: user.id,
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          role: UserRole.customer,
        );

        _isLoading = false;
        notifyListeners();
        return null; // Sukses
      } else {
        _isLoading = false;
        notifyListeners();
        return 'Gagal membuat akun. Silakan coba beberapa saat lagi.';
      }
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _translateAuthError(e.message);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Gagal melakukan registrasi: $e';
    }
  }

  /// Refresh profil dari Supabase (berguna setelah admin mengubah role user)
  Future<void> refreshProfile() async {
    final authUser = SeumaSupabaseService.instance.currentAuthUser;
    if (authUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final profile = await SeumaSupabaseService.instance.getProfile(authUser.id, email: authUser.email);
      final isOwner = UserModel.isSuperAdminEmail(authUser.email ?? _currentUser?.email);
      if (profile != null) {
        if (isOwner || profile.role == UserRole.admin) {
          _currentUser = profile.copyWith(role: UserRole.admin, memberTier: (profile.memberTier == 'New Member' || profile.memberTier == 'Member') ? 'Super Admin' : profile.memberTier);
        } else {
          _currentUser = profile;
        }
        debugPrint('✅ Profil diperbarui: role=${_currentUser!.role.name}');
      } else if (isOwner) {
        _currentUser = (_currentUser ?? UserModel(
          id: authUser.id,
          name: authUser.userMetadata?['name']?.toString() ?? (authUser.email?.split('@').first ?? 'Admin Seuma'),
          email: authUser.email!,
          phone: '',
        )).copyWith(role: UserRole.admin, memberTier: 'Super Admin');
      }
    } catch (e) {
      debugPrint('Error refreshProfile: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _deviceSessionSub?.cancel();
    _activeDeviceSessions.clear();
    await SeumaSupabaseService.instance.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> loginWithGoogle() async {
    try {
      final client = SeumaSupabaseService.instance.client;
      if (client != null) {
        await client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'io.supabase.seuma://login-callback/',
        );
        return true;
      }
    } catch (e) {
      debugPrint('Google OAuth error: $e');
    }
    return false;
  }

  String _translateAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('user already registered') || lower.contains('already exists')) {
      return 'Email ini sudah terdaftar. Silakan pilih tab Masuk.';
    } else if (lower.contains('invalid login credentials') || lower.contains('invalid credentials')) {
      return 'Email atau kata sandi salah. Silakan periksa kembali.';
    } else if (lower.contains('password should be at least')) {
      return 'Kata sandi minimal 6 karakter.';
    } else if (lower.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Harap matikan "Confirm email" di Supabase Providers atau cek inbox email Anda.';
    } else if (lower.contains('database error saving new user')) {
      return 'Database Supabase sedang mengupdate schema. Pastikan script fix_trigger_now.sql telah dijalankan di Supabase SQL Editor.';
    } else if (lower.contains('rate limit')) {
      return 'Terlalu banyak permintaan. Silakan tunggu 1 menit.';
    }
    return message;
  }
}
