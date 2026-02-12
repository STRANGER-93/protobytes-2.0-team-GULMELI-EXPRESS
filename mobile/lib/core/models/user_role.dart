/// Defines the two roles in the JanSawa system.
enum UserRole { citizen, government }

/// Represents a logged-in user.
class AppUser {
  final String id;
  final String name;
  final UserRole role;
  final String location;
  final double walletBalance;
  final String email;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.location,
    this.walletBalance = 0,
    this.email = '',
  });
}

/// Data models used across the app.

class Course {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String duration;
  final String level;
  final int enrolledCount;
  final bool isEnrolled;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.duration,
    this.level = 'Beginner',
    this.enrolledCount = 0,
    this.isEnrolled = false,
  });

  Course copyWith({bool? isEnrolled}) {
    return Course(
      id: id,
      title: title,
      description: description,
      instructor: instructor,
      duration: duration,
      level: level,
      enrolledCount: enrolledCount,
      isEnrolled: isEnrolled ?? this.isEnrolled,
    );
  }
}

class ServiceProvider {
  final String id;
  final String name;
  final String service;
  final String location;
  final double rating;
  final String phone;
  final bool isApproved;
  final String iconName;

  const ServiceProvider({
    required this.id,
    required this.name,
    required this.service,
    required this.location,
    this.rating = 0,
    this.phone = '',
    this.isApproved = true,
    this.iconName = 'build',
  });
}

class Booking {
  final String id;
  final String serviceName;
  final String providerName;
  final String citizenName;
  final String date;
  final String status; // pending, confirmed, completed, cancelled
  final double amount;

  const Booking({
    required this.id,
    required this.serviceName,
    required this.providerName,
    required this.citizenName,
    required this.date,
    this.status = 'pending',
    this.amount = 0,
  });
}

class AnalyticsStat {
  final String label;
  final String value;
  final String icon;
  final double changePercent;

  const AnalyticsStat({
    required this.label,
    required this.value,
    this.icon = 'bar_chart',
    this.changePercent = 0,
  });
}

class InfrastructureReport {
  final String id;
  final String title;
  final String description;
  final String status; // pending, in_progress, resolved
  final String date;
  final String location;
  final String reporterName;

  const InfrastructureReport({
    required this.id,
    required this.title,
    required this.description,
    this.status = 'pending',
    required this.date,
    required this.location,
    required this.reporterName,
  });
}

class Announcement {
  final String id;
  final String title;
  final String content;
  final String date;
  final String target; // all, citizens, providers

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.target = 'all',
  });
}
