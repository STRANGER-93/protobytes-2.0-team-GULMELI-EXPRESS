import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/user_role.dart';
import '../../../shared/theme/app_theme.dart';

class GovReportManagementScreen extends StatefulWidget {
  const GovReportManagementScreen({super.key});

  @override
  State<GovReportManagementScreen> createState() => _GovReportManagementScreenState();
}

class _GovReportManagementScreenState extends State<GovReportManagementScreen> {
  // Local state for demo purposes
  final List<InfrastructureReport> _reports = List.from(MockData.reports);

  void _updateStatus(int index, String newStatus) {
    setState(() {
      final r = _reports[index];
      _reports[index] = InfrastructureReport(
        id: r.id,
        title: r.title,
        description: r.description,
        location: r.location,
        reporterName: r.reporterName,
        date: r.date,
        status: newStatus,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.orange.shade800,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Infrastructure Reports", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade800, AppTheme.crimson],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final report = _reports[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(report.title, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkText)),
                              ),
                              _statusChip(report.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(report.description, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: AppTheme.grey),
                              const SizedBox(width: 4),
                              Text(report.location, style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                              const Spacer(),
                              Text("By ${report.reporterName}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.deepBlue)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text("Update Status:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              _statusAction(index, 'pending', Icons.hourglass_empty, Colors.grey),
                              _statusAction(index, 'in_progress', Icons.shutter_speed, Colors.orange),
                              _statusAction(index, 'resolved', Icons.check_circle_outline, AppTheme.success),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _reports.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusAction(int index, String status, IconData icon, Color color) {
    final isCurrent = _reports[index].status == status;
    return IconButton(
      onPressed: () => _updateStatus(index, status),
      icon: Icon(icon, color: isCurrent ? color : Colors.grey.shade300, size: 22),
      tooltip: status.replaceAll('_', ' ').toUpperCase(),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'resolved': color = AppTheme.success; break;
      case 'in_progress': color = Colors.orange; break;
      default: color = AppTheme.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.replaceAll('_', ' ').toUpperCase(), 
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
