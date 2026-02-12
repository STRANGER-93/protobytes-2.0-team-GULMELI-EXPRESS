import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../shared/theme/app_theme.dart';
import '../widgets/stat_card.dart';

class GovAnalyticsScreen extends StatelessWidget {
  const GovAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = MockData.analytics;
    final bookingsByStatus = <String, int>{};
    for (final b in MockData.bookings) {
      bookingsByStatus[b.status] = (bookingsByStatus[b.status] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text("Analytics")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary Stats ──
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: stats.map((s) {
                return StatCard(
                  label: s.label,
                  value: s.value,
                  icon: _resolveIcon(s.icon),
                  color: _resolveColor(s.icon),
                  changePercent: s.changePercent,
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // ── Booking Status Breakdown ──
            const Text("Booking Status Breakdown",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkText)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: bookingsByStatus.entries.map((e) {
                  final color = _statusColor(e.key);
                  final total = MockData.bookings.length;
                  final pct = (e.value / total * 100).round();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: color)),
                            Text("${e.value} ($pct%)",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: e.value / total,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(color),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // ── Service Distribution ──
            const Text("Provider by Service Type",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkText)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _serviceDistribution().entries.map((e) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: AppTheme.deepBlue,
                    child: Text("${e.value}",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12)),
                  ),
                  label: Text(e.key),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _serviceDistribution() {
    final map = <String, int>{};
    for (final p in MockData.providers) {
      map[p.service] = (map[p.service] ?? 0) + 1;
    }
    return map;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _resolveIcon(String name) {
    switch (name) {
      case 'people':
        return Icons.people;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'school':
        return Icons.school;
      case 'person_add':
        return Icons.person_add;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'pending_actions':
        return Icons.pending_actions;
      default:
        return Icons.bar_chart;
    }
  }

  Color _resolveColor(String name) {
    switch (name) {
      case 'people':
        return AppTheme.deepBlue;
      case 'calendar_today':
        return Colors.green;
      case 'school':
        return Colors.purple;
      case 'person_add':
        return Colors.teal;
      case 'account_balance_wallet':
        return Colors.amber.shade700;
      case 'pending_actions':
        return Colors.orange;
      default:
        return Colors.indigo;
    }
  }
}
