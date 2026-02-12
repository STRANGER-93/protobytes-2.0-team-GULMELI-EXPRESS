import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../shared/theme/app_theme.dart';

class GovProviderManagementScreen extends StatefulWidget {
  const GovProviderManagementScreen({super.key});

  @override
  State<GovProviderManagementScreen> createState() =>
      _GovProviderManagementScreenState();
}

class _GovProviderManagementScreenState
    extends State<GovProviderManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = MockData.providers.where((p) => !p.isApproved).toList();
    final approved = MockData.providers.where((p) => p.isApproved).toList();

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.deepBlue,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  "Provider Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.deepBlue, Color(0xFF1E3A8A)],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.success,
                indicatorWeight: 4,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: [
                  Tab(text: "Pending (${pending.length})"),
                  Tab(text: "Approved (${approved.length})"),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Pending Tab ──
            _buildList(pending, true),

            // ── Approved Tab ──
            _buildList(approved, false),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> providers, bool isPending) {
    if (providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text("No ${isPending ? 'pending' : 'approved'} providers",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: providers.length,
      itemBuilder: (ctx, index) {
        final p = providers[index];
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (index / providers.length) * 0.5,
              1.0,
              curve: Curves.easeOut,
            ),
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              AppTheme.deepBlue.withValues(alpha: 0.1),
                          child: Text(p.name[0],
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.deepBlue)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppTheme.darkText)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.work_outline_rounded,
                                      size: 14, color: AppTheme.grey),
                                  const SizedBox(width: 4),
                                  Text(p.service,
                                      style: const TextStyle(
                                          fontSize: 14, color: AppTheme.grey)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.location_on_outlined,
                                      size: 14, color: AppTheme.grey),
                                  const SizedBox(width: 4),
                                  Text(p.location,
                                      style: const TextStyle(
                                          fontSize: 14, color: AppTheme.grey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (p.isApproved)
                          Container(
                             padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text("Verified",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.success)),
                          ),
                      ],
                    ),
                    if (isPending) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("${p.name} approved! ✓"),
                                      backgroundColor: AppTheme.success),
                                );
                              },
                              icon: const Icon(Icons.check_circle_outline,
                                  color: Colors.white, size: 20),
                              label: const Text("Approve",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.success,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("${p.name} rejected"),
                                      backgroundColor: AppTheme.crimson),
                                );
                              },
                              icon: const Icon(Icons.close,
                                  size: 20, color: AppTheme.crimson),
                              label: const Text("Reject",
                                  style: TextStyle(
                                      color: AppTheme.crimson,
                                      fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.crimson),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
