import 'package:flutter/material.dart';
import '../../../shared/theme/app_theme.dart';

/// Simple local-only report model (no backend endpoint exists for infrastructure reports).
class _InfraReport {
  final String id;
  final String title;
  final String description;
  final String location;
  final String reporterName;
  final String date;
  final String status;

  const _InfraReport({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.reporterName,
    required this.date,
    required this.status,
  });

  _InfraReport copyWith({String? status}) => _InfraReport(
    id: id,
    title: title,
    description: description,
    location: location,
    reporterName: reporterName,
    date: date,
    status: status ?? this.status,
  );
}

class GovReportManagementScreen extends StatefulWidget {
  const GovReportManagementScreen({super.key});

  @override
  State<GovReportManagementScreen> createState() =>
      _GovReportManagementScreenState();
}

class _GovReportManagementScreenState extends State<GovReportManagementScreen> {
  final List<_InfraReport> _reports = [];

  void _updateStatus(int index, String newStatus) {
    setState(() {
      _reports[index] = _reports[index].copyWith(status: newStatus);
    });
  }

  void _showCreateDialog() {
    String title = '';
    String description = '';
    String location = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New Report",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (val) => title = val,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (val) => description = val,
              maxLines: 2,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (val) => location = val,
              decoration: const InputDecoration(labelText: "Location"),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (title.isNotEmpty && description.isNotEmpty) {
                    setState(() {
                      _reports.insert(
                        0,
                        _InfraReport(
                          id: 'r${DateTime.now().millisecondsSinceEpoch}',
                          title: title,
                          description: description,
                          location: location.isNotEmpty ? location : 'Unknown',
                          reporterName: 'Admin',
                          date: DateTime.now().toString().substring(0, 10),
                          status: 'pending',
                        ),
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Submit Report",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              title: const Text(
                "Infrastructure Reports",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
          if (_reports.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.report_problem_rounded,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No reports yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap + to file a new report",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final report = _reports[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  report.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.darkText,
                                  ),
                                ),
                              ),
                              _statusChip(report.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            report.description,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppTheme.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                report.location,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.grey,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "By ${report.reporterName}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.deepBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                "Update Status:",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _statusAction(
                                index,
                                'pending',
                                Icons.hourglass_empty,
                                Colors.grey,
                              ),
                              _statusAction(
                                index,
                                'in_progress',
                                Icons.shutter_speed,
                                Colors.orange,
                              ),
                              _statusAction(
                                index,
                                'resolved',
                                Icons.check_circle_outline,
                                AppTheme.success,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: _reports.length),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: Colors.orange.shade800,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "New Report",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _statusAction(int index, String status, IconData icon, Color color) {
    final isCurrent = _reports[index].status == status;
    return IconButton(
      onPressed: () => _updateStatus(index, status),
      icon: Icon(
        icon,
        color: isCurrent ? color : Colors.grey.shade300,
        size: 22,
      ),
      tooltip: status.replaceAll('_', ' ').toUpperCase(),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'resolved':
        color = AppTheme.success;
        break;
      case 'in_progress':
        color = Colors.orange;
        break;
      default:
        color = AppTheme.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
