import 'package:flutter/material.dart';
import '../../../core/services/governance_service.dart';
import '../../../core/models/api_models.dart' as api;
import '../../../shared/theme/app_theme.dart';

class GovProviderManagementScreen extends StatefulWidget {
  const GovProviderManagementScreen({super.key});

  @override
  State<GovProviderManagementScreen> createState() => _GovProviderManagementScreenState();
}

class _GovProviderManagementScreenState extends State<GovProviderManagementScreen> with TickerProviderStateMixin {
  final GovernanceService _governanceService = GovernanceService();
  late TabController _tabController;
  
  List<api.ProviderProfile> _pending = [];
  List<api.ProviderProfile> _approved = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await _governanceService.getPendingProviders();
    setState(() {
      _pending = results.where((p) => !p.isVerified).toList();
      _approved = results.where((p) => p.isVerified).toList();
      _isLoading = false;
    });
  }

  Future<void> _verify(int id, bool status) async {
    final success = await _governanceService.verifyProvider(id, verified: status);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status ? "Provider Approved ✓" : "Provider Rejected"), backgroundColor: status ? AppTheme.success : AppTheme.crimson),
      );
      _loadData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120.0,
            pinned: true,
            backgroundColor: AppTheme.deepBlue,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text("Provider Management", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              background: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.deepBlue, AppTheme.crimson]))),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: "Pending (${_pending.length})"),
                Tab(text: "Approved (${_approved.length})"),
              ],
            ),
          ),
        ],
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_pending, true),
                _buildList(_approved, false),
              ],
            ),
      ),
    );
  }

  Widget _buildList(List<api.ProviderProfile> providers, bool isPending) {
    if (providers.isEmpty) {
      return Center(child: Text("No ${isPending ? 'pending' : 'approved'} providers"));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: providers.length,
        itemBuilder: (context, index) {
          final p = providers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(child: Text(p.name[0])),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(p.service, style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                      ]),
                    ),
                  ],
                ),
                if (isPending) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: ElevatedButton(onPressed: () => _verify(p.id, true), child: const Text("Approve"))),
                      const SizedBox(width: 10),
                      Expanded(child: OutlinedButton(onPressed: () => _verify(p.id, false), child: const Text("Reject"))),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
