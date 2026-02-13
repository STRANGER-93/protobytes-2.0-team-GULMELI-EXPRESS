/// Defines the three roles in the JanSewa system.
enum UserRole { citizen, provider, government }

/// Represents a logged-in user.
class AppUser {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String location;
  final double walletBalance;
  final String email;
  final String? photo;
  final int? municipalityId;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.location,
    this.walletBalance = 0,
    this.email = '',
    this.photo,
    this.municipalityId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Backend verify-otp returns {access, refresh, user: {...}}
    // Extract user data from nested key if present
    final userData = json['user'] as Map<String, dynamic>? ?? json;

    // Determine role
    UserRole role = UserRole.citizen;
    final backendRole = userData['role'] ?? '';
    if (backendRole == 'municipality_admin' || backendRole == 'government') {
      role = UserRole.government;
    } else if (backendRole == 'provider') {
      role = UserRole.provider;
    }

    return AppUser(
      id: userData['id']?.toString() ?? '',
      name: userData['name'] ?? '',
      phone: userData['phone'] ?? '',
      role: role,
      location: userData['municipality_detail'] != null
          ? (userData['municipality_detail']['name'] ?? 'Unknown')
          : 'Unknown',
      walletBalance:
          double.tryParse(userData['wallet_balance']?.toString() ?? '0') ?? 0,
      email: userData['email'] ?? '',
      photo: userData['photo'],
      municipalityId: userData['municipality'] is int
          ? userData['municipality']
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'role': role == UserRole.government ? 'municipality_admin' : role.name,
    'location': location,
    'wallet_balance': walletBalance,
    'email': email,
    'photo': photo,
    'municipality': municipalityId,
  };

  factory AppUser.fromStoredJson(Map<String, dynamic> json) {
    UserRole role = UserRole.citizen;
    final r = json['role'] ?? '';
    if (r == 'municipality_admin' || r == 'government') {
      role = UserRole.government;
    } else if (r == 'provider') {
      role = UserRole.provider;
    }
    return AppUser(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: role,
      location: json['location'] ?? 'Unknown',
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
      email: json['email'] ?? '',
      photo: json['photo'],
      municipalityId: json['municipality'],
    );
  }
}

/// ----------------------------------------------------------------
/// Legacy mock-only model classes – used by gov screens that have
/// no backend endpoints yet. Do NOT use for API-connected features.
/// ----------------------------------------------------------------

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
