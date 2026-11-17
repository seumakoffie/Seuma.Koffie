// lib/state/auth_state.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthManager extends ChangeNotifier {
  static final AuthManager instance = AuthManager._internal();
  AuthManager._internal() {
    _initAuthListener();
  }

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

  void _initAuthListener() {
    try {
      final client = SeumaSupabaseService.instance.client;
      if (client == null) return;

      // Cek sesi yang sudah tersimpan saat web dibuka
      final currentSession = client.auth.currentSession;
      if (currentSession != null) {
        _fetchAndSetProfile(currentSession.user.id);
      }

      // Dengarkan perubahan login / logout secara realtime
      client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          _fetchAndSetProfile(session.user.id);
        } else {
          _currentUser = null;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Error initAuthListener: $e');
    }
  }

  Future<void> _fetchAndSetProfile(String userId) async {
    UserModel? profile = await SeumaSupabaseService.instance.getProfile(userId);
    if (profile != null) {
      _currentUser = profile;
      notifyListeners();
      return;
    }

    // Auto-heal: Jika akun ada di auth.users tapi belum ada di public.profiles,
    // langsung buat baris profilnya agar data tersinkron sempurna di database.
    final authUser = SeumaSupabaseService.instance.currentAuthUser;
    if (authUser != null && authUser.id == userId) {
      try {
        final client = SeumaSupabaseService.instance.client;
        if (client != null) {
          final fallbackName = authUser.userMetadata?['name']?.toString() ??
              authUser.email?.split('@').first ??
              'Pelanggan';
          final fallbackPhone = authUser.userMetadata?['phone']?.toString() ?? '';
          
          await client.from('profiles').upsert({
            'id': authUser.id,
            'name': fallbackName,
            'email': authUser.email ?? '',
            'phone': fallbackPhone,
            'role': 'customer',
            'member_tier': 'New Member',
            'points': 100,
            'encryption_iv': authUser.id.replaceAll('-', '').substring(0, 16),
          });

          profile = await SeumaSupabaseService.instance.getProfile(userId);
          if (profile != null) {
            _currentUser = profile;
            notifyListeners();
            return;
          }
        }
      } catch (e) {
        debugPrint('Auto-heal profile sync info: $e');
      }
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
        UserModel? profile = await SeumaSupabaseService.instance.getProfile(user.id);
        
        // Jika profil belum terambil sesaat setelah trigger
        if (profile == null) {
          await Future.delayed(const Duration(milliseconds: 400));
          profile = await SeumaSupabaseService.instance.getProfile(user.id);
        }

        _currentUser = profile ?? UserModel(
          id: user.id,
          name: user.userMetadata?['name']?.toString() ?? user.email?.split('@').first ?? 'Pelanggan',
          email: user.email ?? identifier,
          phone: user.userMetadata?['phone']?.toString() ?? '',
          role: UserRole.customer,
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

  Future<void> logout() async {
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
