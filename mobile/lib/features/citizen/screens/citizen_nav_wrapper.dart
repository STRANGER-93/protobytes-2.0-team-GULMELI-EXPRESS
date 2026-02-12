import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
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

  final _screens = const [
    CitizenDashboardScreen(),
    CitizenCourseListScreen(),
    CitizenProviderListScreen(),
    CitizenBookingsScreen(),
    CitizenProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Guard: if somehow a non-citizen accesses this, kick them out
    if (!AppStateProvider.of(context).isCitizen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],
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
            selectedItemColor: Colors.indigo,
            unselectedItemColor: Colors.grey.shade400,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.school), label: "Courses"),
              BottomNavigationBarItem(icon: Icon(Icons.storefront), label: "Services"),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Bookings"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}
