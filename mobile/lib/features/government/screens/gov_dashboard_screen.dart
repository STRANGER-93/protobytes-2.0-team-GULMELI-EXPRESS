import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/state/app_state.dart';
import '../../../shared/theme/app_theme.dart';
import '../widgets/stat_card.dart';

class GovDashboardScreen extends StatefulWidget {
  const GovDashboardScreen({super.key});

  @override
  State<GovDashboardScreen> createState() => _GovDashboardScreenState();
}

class _GovDashboardScreenState extends State<GovDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppStateProvider.of(context).currentUser!;
    final pendingCount =
        MockData.providers.where((p) => !p.isApproved).length;
    final pendingBookings =
        MockData.bookings.where((b) => b.status == 'pending').length;

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header Section ──
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.deepBlue, AppTheme.crimson],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 50.0, left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Government Portal",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(color: Colors.white)),
                                const SizedBox(height: 4),
                                Text("Welcome, ${user.name}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white70)),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                AppStateProvider.of(context).logout();
                                Navigator.pushReplacementNamed(context, '/');
                              },
                              icon: const Icon(Icons.logout,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // ── Stats Grid Inside Header Overflow ──
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // ── Stats Grid ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 0),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
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
                    color: AppTheme.success,
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
                    color: AppTheme.warning,
                    changePercent: -10,
                  ),
                ],
              ),
            ),

            // ── Quick Actions Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text("Quick Actions",
                    style: Theme.of(context).textTheme.titleLarge),
              ),
            ),

            // ── Quick Actions List ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
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
                    AppTheme.success,
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
                ]),
              ),
            ),

            // ── Recent Activity Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text("Recent Activity",
                    style: Theme.of(context).textTheme.titleLarge),
              ),
            ),

            // ── Recent Activity List ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final booking = MockData.bookings[index];
                    return _activityTile(booking);
                  },
                  childCount: MockData.bookings.take(5).length,
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String title,
      String subtitle, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppTheme.darkText)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: AppTheme.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _activityTile(dynamic b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 10, color: AppTheme.deepBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: AppTheme.darkText),
                    children: [
                      TextSpan(
                          text: b.citizenName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: " booked "),
                      TextSpan(
                          text: b.serviceName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: " from "),
                      TextSpan(
                          text: b.providerName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(b.date,
                    style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
