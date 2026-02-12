import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../data/mock_data.dart';

/// Centralized app state — manages the current user and role.
/// Wrap your MaterialApp with AppStateProvider to access anywhere.
class AppStateProvider extends StatefulWidget {
  final Widget Function(AppUser? user) builder;

  const AppStateProvider({super.key, required this.builder});

  @override
  State<AppStateProvider> createState() => AppStateProviderState();

  static AppStateProviderState of(BuildContext context) {
    final state = context.findAncestorStateOfType<AppStateProviderState>();
    assert(state != null, 'AppStateProvider not found in widget tree');
    return state!;
  }
}

class AppStateProviderState extends State<AppStateProvider> {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isCitizen => _currentUser?.role == UserRole.citizen;
  bool get isGovernment => _currentUser?.role == UserRole.government;

  void loginAs(UserRole role) {
    setState(() {
      _currentUser = role == UserRole.citizen
          ? MockData.citizenUser
          : MockData.governmentUser;
    });
  }

  void logout() {
    setState(() => _currentUser = null);
  }

  @override
  Widget build(BuildContext context) => widget.builder(_currentUser);
}
