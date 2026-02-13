import 'package:flutter/material.dart';
import '../../../core/services/governance_service.dart';
import '../../../core/models/api_models.dart';
import '../../../core/state/app_state.dart';
import '../../../shared/theme/app_theme.dart';

class GovDashboardScreen extends StatefulWidget {
  const GovDashboardScreen({super.key});

  @override
  State<GovDashboardScreen> createState() => _GovDashboardScreenState();
}

class _GovDashboardScreenState extends State<GovDashboardScreen>
    with SingleTickerProviderStateMixin {
  final GovernanceService _governanceService = GovernanceService();
  GovernanceStats? _stats;
  bool _isLoading = true;
  
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await _governanceService.getDashboardStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              _buildHeader(),
              
              if (_isLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else ...[
                _buildSectionHeader("Core Systems Management"),
                _buildManagementHub(),
                
                _buildSectionHeader("Community & Infrastructure"),
                _buildCommunityHub(),
                
                _buildSectionHeader("System Administration"),
                _buildAdminActions(),
              ],
              
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40)),
            ),
          ),
          Positioned(
            left: 20, top: 60, right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("COMMAND CENTER", style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        Text("Gov Portal", style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(_stats?.municipality['name'] ?? "Municipality Admin", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        AppStateProvider.of(context).logout();
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildQuickAnalyticsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAnalyticsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickStat(_stats?.providers.totalProviders.toString() ?? "0", "Providers", Icons.engineering_rounded),
          Container(width: 1, height: 30, color: Colors.white24),
          _buildQuickStat(_stats?.bookings.total.toString() ?? "0", "Bookings", Icons.event_available_rounded),
          Container(width: 1, height: 30, color: Colors.white24),
          _buildQuickStat(_stats?.providers.pendingProviders.toString() ?? "0", "Pending", Icons.pending_actions_rounded),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 14),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildManagementHub() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          _buildHubCard("Verify Providers", "${_stats?.providers.pendingProviders ?? 0} Pending", Icons.verified_user_rounded, AppTheme.deepBlue, '/gov/providers'),
          _buildHubCard("Task Overview", "${_stats?.bookings.completed ?? 0} Completed", Icons.assignment_rounded, AppTheme.success, '/gov/bookings'),
        ],
      ),
    );
  }

  Widget _buildCommunityHub() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          _buildHubCard("User Base", "Registry", Icons.people_rounded, Colors.indigo, '/gov/users'),
          _buildHubCard("Complaints", "Infra & Service", Icons.report_problem_rounded, AppTheme.crimson, '/gov/reports'),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildAdminTile("Training Center", "Manage vocational courses", Icons.school_rounded, Colors.purple, '/gov/training'),
          _buildAdminTile("Announcements", "Citizen broadcasts", Icons.campaign_rounded, Colors.teal, '/gov/announcements'),
          _buildAdminTile("Economic Analytics", "Retained Earnings: ${_stats?.earnings.formatted ?? '0'}", Icons.insights_rounded, Colors.blueGrey, '/gov/analytics'),
        ]),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
      ),
    );
  }

  Widget _buildHubCard(String title, String subtitle, IconData icon, Color color, String route) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminTile(String title, String subtitle, IconData icon, Color color, String route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))]),
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, route),
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
