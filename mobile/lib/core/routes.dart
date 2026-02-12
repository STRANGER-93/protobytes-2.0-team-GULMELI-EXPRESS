import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/citizen/screens/citizen_nav_wrapper.dart';
import '../features/citizen/screens/citizen_course_list_screen.dart';
import '../features/citizen/screens/citizen_course_detail_screen.dart';
import '../features/citizen/screens/citizen_provider_list_screen.dart';
import '../features/citizen/screens/citizen_provider_detail_screen.dart';
import '../features/citizen/screens/citizen_bookings_screen.dart';
import '../features/citizen/screens/citizen_profile_screen.dart';
import '../features/government/screens/gov_user_management_screen.dart';
import '../features/government/screens/gov_report_management_screen.dart';
import '../features/government/screens/gov_announcement_screen.dart';
import '../features/government/screens/gov_training_management_screen.dart';
import '../features/government/screens/gov_analytics_screen.dart';
import 'state/app_state.dart';
import 'models/user_role.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings, BuildContext context) {
    // Get current role from state
    final appState = AppStateProvider.of(context);
    final role = appState.currentUser?.role;

    switch (settings.name) {
      // ── Public routes ───────────────────────────
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      // ── Citizen routes ──────────────────────────
      case '/citizen/dashboard':
        if (role != UserRole.citizen) return _accessDenied(settings);
        return MaterialPageRoute(builder: (_) => const CitizenNavWrapper());
      case '/citizen/courses':
        if (role != UserRole.citizen) return _accessDenied(settings);
        return MaterialPageRoute(builder: (_) => const CitizenCourseListScreen());
      case '/citizen/course-detail':
        if (role != UserRole.citizen) return _accessDenied(settings);
        final courseId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CitizenCourseDetailScreen(courseId: courseId ?? ''),
        );
      case '/citizen/providers':
        if (role != UserRole.citizen) return _accessDenied(settings);
        return MaterialPageRoute(builder: (_) => const CitizenProviderListScreen());
      case '/citizen/provider-detail':
        if (role != UserRole.citizen) return _accessDenied(settings);
        final providerId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CitizenProviderDetailScreen(providerId: providerId ?? ''),
        );
      case '/citizen/bookings':
        if (role != UserRole.citizen) return _accessDenied(settings);
        return MaterialPageRoute(builder: (_) => const CitizenBookingsScreen());
      case '/citizen/profile':
        if (role != UserRole.citizen) return _accessDenied(settings);
        return MaterialPageRoute(builder: (_) => const CitizenProfileScreen());

      // ── Government routes ───────────────────────
      case '/gov/dashboard':
        if (role != UserRole.government) return _accessDenied(settings);
        return MaterialPageRoute(builder: (_) => const GovDashboardScreen());
      case '/gov/providers':
        if (role != UserRole.government) return _accessDenied(settings);
        return MaterialPageRoute(builder: (_) => const GovProviderManagementScreen());
      case '/gov/bookings':
        if (role != UserRole.government) return _accessDenied(settings);
        return MaterialPageRoute(builder: (_) => const GovBookingManagementScreen());
      case '/gov/training':
        if (role != UserRole.government) return _accessDenied(settings);
        return MaterialPageRoute(builder: (_) => const GovTrainingManagementScreen());
      case '/gov/analytics':
        if (role != UserRole.government) return _accessDenied(settings);
        return MaterialPageRoute(builder: (_) => const GovAnalyticsScreen());
      case '/gov/users':
        if (role != UserRole.government) return _accessDenied(settings);
        return MaterialPageRoute(builder: (_) => const GovUserManagementScreen());
      case '/gov/reports':
        if (role != UserRole.government) return _accessDenied(settings);
        return MaterialPageRoute(builder: (_) => const GovReportManagementScreen());
      case '/gov/announcements':
        if (role != UserRole.government) return _accessDenied(settings);
        return MaterialPageRoute(builder: (_) => const GovAnnouncementScreen());

      default:
        return _notFound(settings);
    }
  }

  static MaterialPageRoute _accessDenied(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text(
            'Access Denied',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  static MaterialPageRoute _notFound(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}
