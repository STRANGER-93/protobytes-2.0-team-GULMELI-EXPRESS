import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_role.dart';
import '../api_client.dart';

class AppState extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isProviderMode = false;
  bool _isLoading = true; // starts true until auto-login check done

  static const _storage = FlutterSecureStorage();
  static const _userKey = 'stored_user';

  AppUser? get currentUser => _currentUser;
  bool get isProviderMode => _isProviderMode;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  bool get isCitizen => _currentUser?.role == UserRole.citizen;
  bool get isProvider => _currentUser?.role == UserRole.provider;
  bool get isGovernment => _currentUser?.role == UserRole.government;

  /// Attempt to restore session from secure storage.
  Future<void> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();
    try {
      final api = ApiClient();
      final loaded = await api.loadStoredTokens();
      if (!loaded) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      // Restore user data
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = AppUser.fromStoredJson(map);
      }
    } catch (_) {
      // If anything fails, just start fresh
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Set user after successful OTP verification.
  Future<void> setRealUser(AppUser user) async {
    _currentUser = user;
    // Persist user info
    try {
      await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    } catch (_) {}
    notifyListeners();
  }

  void loginAs(UserRole role) {
    // Disable demo login bypass in production
    if (!kDebugMode) {
      debugPrint('loginAs() is disabled in release builds');
      return;
    }
    // Legacy support for demo buttons
    _currentUser = AppUser(
      id: "demo",
      name: role == UserRole.citizen
          ? "Demo Citizen"
          : role == UserRole.provider
          ? "Demo Provider"
          : "Gov Admin",
      phone: role == UserRole.citizen
          ? "9841001122"
          : role == UserRole.provider
          ? "9841002233"
          : "9841003344",
      role: role,
      location: "Bagmati, Kathmandu",
      walletBalance: 1500,
      email: "demo@example.com",
    );
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _isProviderMode = false;
    final api = ApiClient();
    api.setToken(null);
    try {
      await _storage.delete(key: _userKey);
      await api.clearTokens();
    } catch (_) {}
    notifyListeners();
  }

  void toggleProviderMode() {
    if (isCitizen) {
      _isProviderMode = !_isProviderMode;
      notifyListeners();
    }
  }
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    if (provider == null || provider.notifier == null) {
      throw FlutterError(
        'AppStateProvider.of() called with a context that does not contain an AppStateProvider.\n'
        'No AppStateProvider ancestor could be found starting from the context that was passed to AppStateProvider.of().',
      );
    }
    return provider.notifier!;
  }
}
