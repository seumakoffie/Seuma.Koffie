// lib/state/auth_state.dart
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthManager extends ChangeNotifier {
  static final AuthManager instance = AuthManager._();
  AuthManager._();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<bool> login({
    required String identifier, // email or phone
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Mock API delay for realistic UX
    await Future.delayed(const Duration(milliseconds: 600));

    _currentUser = UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: identifier.contains('@') ? identifier.split('@').first : 'Pelanggan Seuma',
      email: identifier.contains('@') ? identifier : '$identifier@seumakoffie.id',
      phone: identifier.contains('@') ? '08123456789' : identifier,
      points: 150,
      memberTier: 'Gold Member',
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

    _currentUser = UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      points: 250, // Bonus points for new registrations
      memberTier: 'New Member',
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

