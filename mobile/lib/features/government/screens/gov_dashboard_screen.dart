import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/state/app_state.dart';
import '../../../shared/theme/app_theme.dart';
import '../widgets/stat_card.dart';

class GovDashboardScreen extends StatelessWidget {
  const GovDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppStateProvider.of(context).currentUser!;
    final analytics = MockData.analytics;
    final pendingCount =
        MockData.providers.where((p) => !p.isApproved).length;
    final pendingBookings =
        MockData.bookings.where((b) => b.status == 'pending').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Government Portal",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.darkText)),
                      Text("Welcome, ${user.name}",
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade600)),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      AppStateProvider.of(context).logout();
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    icon: const Icon(Icons.logout, color: AppTheme.crimson),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Stats Grid ──
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    label: "Total Providers",
                    value: "${MockData.providers.length}",
                    icon: Icons.people,
                    color: AppTheme.deepBlue,
                    changePercent: 12,
                  ),
                  StatCard(
                    label: "Active Bookings",
                    value: "${MockData.bookings.length}",
                    icon: Icons.calendar_today,
                    color: Colors.green,
                    changePercent: 8,
                  ),
                  StatCard(
                    label: "Training Courses",
                    value: "${MockData.courses.length}",
                    icon: Icons.school,
                    color: Colors.purple,
                    changePercent: 20,
                  ),
                  StatCard(
                    label: "Pending Approvals",
                    value: "$pendingCount",
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                    changePercent: -10,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Quick Actions ──
              const Text("Quick Actions",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkText)),
              const SizedBox(height: 12),
              _actionTile(
                context,
                Icons.people_alt,
                "Provider Management",
                "$pendingCount pending approvals",
                AppTheme.deepBlue,
                () => Navigator.pushNamed(context, '/gov/providers'),
              ),
              _actionTile(
                context,
                Icons.calendar_month,
                "Booking Management",
                "$pendingBookings pending bookings",
                Colors.green,
                () => Navigator.pushNamed(context, '/gov/bookings'),
              ),
              _actionTile(
                context,
                Icons.school,
                "Training Programs",
                "${MockData.courses.length} active courses",
                Colors.purple,
                () => Navigator.pushNamed(context, '/gov/training'),
              ),
              _actionTile(
                context,
                Icons.bar_chart,
                "Analytics",
                "View system statistics",
                Colors.teal,
                () => Navigator.pushNamed(context, '/gov/analytics'),
              ),
              const SizedBox(height: 28),

              // ── Recent Activity ──
              const Text("Recent Activity",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkText)),
              const SizedBox(height: 12),
              ...MockData.bookings.take(3).map((b) => _activityTile(b)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String title,
      String subtitle, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityTile(dynamic b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: AppTheme.deepBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${b.citizenName} booked ${b.serviceName} from ${b.providerName}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(b.date,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
