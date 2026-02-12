import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/training/screens/course_list_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case "/home":
        return MaterialPageRoute(builder: (_) => const CourseListScreen());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text("Route not found"))));
    }
  }
}
