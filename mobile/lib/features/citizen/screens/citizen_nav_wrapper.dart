import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../shared/theme/app_theme.dart';
import 'citizen_dashboard_screen.dart';
import 'citizen_course_list_screen.dart';
import 'citizen_provider_list_screen.dart';
import 'citizen_bookings_screen.dart';
import 'citizen_profile_screen.dart';

class CitizenNavWrapper extends StatefulWidget {
  const CitizenNavWrapper({super.key});

  @override
  State<CitizenNavWrapper> createState() => _CitizenNavWrapperState();
}

class _CitizenNavWrapperState extends State<CitizenNavWrapper> {
  int _selectedIndex = 0;
  bool? _lastMode;

  // Citizen Screens (Hire Mode)
  final _citizenScreens = const [
    CitizenDashboardScreen(),
    CitizenCourseListScreen(),
    CitizenProviderListScreen(),
    CitizenBookingsScreen(),
    CitizenProfileScreen(),
  ];

  // Provider Screens (Work Mode)
  final _providerScreens = const [
    CitizenDashboardScreen(), // Unified Dashboard
    Scaffold(body: Center(child: Text("My Services (Coming Soon)"))),
    Scaffold(body: Center(child: Text("Service Requests (Coming Soon)"))),
    Scaffold(body: Center(child: Text("Earnings (Coming Soon)"))),
    CitizenProfileScreen(), // Profile is shared to allow switching back
  ];

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isProvider = appState.isProviderMode;

    // Reset index to dashboard when switching modes
    if (_lastMode != null && _lastMode != isProvider) {
      _selectedIndex = 0;
    }
    _lastMode = isProvider;

    // Guard: if somehow a non-citizen accesses this, kick them out
    if (!appState.isCitizen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const SizedBox.shrink();
    }

    final screens = isProvider ? _providerScreens : _citizenScreens;
    final themeColor = isProvider ? AppTheme.success : AppTheme.deepBlue;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            selectedItemColor: themeColor,
            unselectedItemColor: Colors.grey.shade400,
            items: isProvider
                ? const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard_rounded), label: "Work"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.list_alt_rounded), label: "Services"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.notifications_active_rounded),
                        label: "Requests"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.account_balance_wallet_rounded),
                        label: "Earnings"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.person_rounded), label: "Profile"),
                  ]
                : const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home_filled), label: "Home"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.school), label: "Courses"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.storefront), label: "Services"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.calendar_month), label: "Bookings"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.person), label: "Profile"),
                  ],
          ),
        ),
      ),
    );
  }
}
