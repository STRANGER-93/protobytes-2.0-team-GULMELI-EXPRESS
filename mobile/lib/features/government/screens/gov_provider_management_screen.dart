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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = MockData.providers.where((p) => !p.isApproved).toList();
    final approved = MockData.providers.where((p) => p.isApproved).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Provider Management"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: "Pending (${pending.length})"),
            Tab(text: "Approved (${approved.length})"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Pending Tab ──
          pending.isEmpty
              ? const Center(child: Text("No pending approvals"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pending.length,
                  itemBuilder: (ctx, i) => _providerCard(pending[i], true),
                ),

          // ── Approved Tab ──
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: approved.length,
            itemBuilder: (ctx, i) => _providerCard(approved[i], false),
          ),
        ],
      ),
    );
  }

  Widget _providerCard(dynamic p, bool showActions) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.deepBlue.withValues(alpha: 0.1),
                  child: Text(p.name[0],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepBlue)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      Text("${p.service} • ${p.location}",
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                if (p.isApproved)
                  const Chip(
                    label: Text("Verified",
                        style: TextStyle(fontSize: 11, color: Colors.green)),
                    backgroundColor: Color(0xFFE8F5E9),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("${p.name} approved! ✓"),
                              backgroundColor: Colors.green),
                        );
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Approve"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("${p.name} rejected"),
                              backgroundColor: Colors.red),
                        );
                      },
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text("Reject"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
