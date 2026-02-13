import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../api_client.dart';

class AppState extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isProviderMode = false;

  AppUser? get currentUser => _currentUser;
  bool get isProviderMode => _isProviderMode;
  bool get isAuthenticated => _currentUser != null;

  bool get isCitizen => _currentUser?.role == UserRole.citizen;
  bool get isGovernment => _currentUser?.role == UserRole.government;

  void setRealUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void loginAs(UserRole role) {
    // Legacy support for demo buttons
    _currentUser = AppUser(
      id: "demo",
      name: role == UserRole.citizen ? "Demo Citizen" : "Gov Admin",
      phone: role == UserRole.citizen ? "9841001122" : "9841003344",
      role: role,
      location: "Bagmati, Kathmandu",
      walletBalance: 1500,
      email: "demo@example.com",
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isProviderMode = false;
    ApiClient().setToken(null);
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
    return provider!.notifier!;
  }
}
