import 'package:flutter/material.dart';
import '../../../core/services/governance_service.dart';
import '../../../core/models/api_models.dart';
import '../../../shared/theme/app_theme.dart';
import '../widgets/stat_card.dart';

class GovAnalyticsScreen extends StatefulWidget {
  const GovAnalyticsScreen({super.key});

  @override
  State<GovAnalyticsScreen> createState() => _GovAnalyticsScreenState();
}

class _GovAnalyticsScreenState extends State<GovAnalyticsScreen> {
  final GovernanceService _governanceService = GovernanceService();
  GovernanceStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await _governanceService.getDashboardStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text("Analytics")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
          ? const Center(child: Text("Failed to load analytics data"))
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Summary Stats from API ──
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        StatCard(
                          label: 'Total Providers',
                          value: '${_stats!.providers.totalProviders}',
                          icon: Icons.people,
                          color: AppTheme.deepBlue,
                        ),
                        StatCard(
                          label: 'Verified Providers',
                          value: '${_stats!.providers.verifiedProviders}',
                          icon: Icons.verified_user,
                          color: Colors.green,
                        ),
                        StatCard(
                          label: 'Completed Bookings',
                          value: '${_stats!.bookings.completed}',
                          icon: Icons.calendar_today,
                          color: Colors.blue,
                        ),
                        StatCard(
                          label: 'Total Bookings',
                          value: '${_stats!.bookings.total}',
                          icon: Icons.event_available,
                          color: Colors.teal,
                        ),
                        StatCard(
                          label: 'Local Earnings',
                          value: _stats!.earnings.formatted,
                          icon: Icons.account_balance_wallet,
                          color: Colors.amber.shade700,
                        ),
                        StatCard(
                          label: 'Pending Approvals',
                          value: '${_stats!.providers.pendingProviders}',
                          icon: Icons.pending_actions,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Booking Completion Rate ──
                    const Text(
                      "Booking Completion Rate",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkText,
                      ),
                    ),
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
                        children: [
                          _buildProgressRow(
                            "Completed",
                            _stats!.bookings.completed,
                            _stats!.bookings.total,
                            Colors.blue,
                          ),
                          const SizedBox(height: 14),
                          _buildProgressRow(
                            "Pending",
                            _stats!.bookings.total - _stats!.bookings.completed,
                            _stats!.bookings.total,
                            Colors.orange,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "COMPLETION RATE",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.grey,
                                ),
                              ),
                              Text(
                                "${_stats!.bookings.completionRate.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _stats!.bookings.completionRate >= 50
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Top Skills ──
                    if (_stats!.topSkills.isNotEmpty) ...[
                      const Text(
                        "Top Active Skills",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _stats!.topSkills.map((skill) {
                          final name = skill['skill_category'] ?? 'Unknown';
                          final count = skill['count'] ?? 0;
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundColor: AppTheme.deepBlue,
                              child: Text(
                                "$count",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            label: Text(
                              name
                                  .toString()
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // ── Provider Stats ──
                    const Text(
                      "Provider Breakdown",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkText,
                      ),
                    ),
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
                        children: [
                          _buildInfoRow(
                            "Active Providers",
                            "${_stats!.providers.activeProviders}",
                          ),
                          _buildInfoRow(
                            "CTEVT Certified",
                            "${_stats!.providers.ctevtCertified}",
                          ),
                          _buildInfoRow(
                            "Retention Rate",
                            "${_stats!.providers.retentionRate.toStringAsFixed(1)}%",
                          ),
                          _buildInfoRow(
                            "Pending Verification",
                            "${_stats!.providers.pendingProviders}",
                          ),
                        ],
                      ),
                    ),

                    // ── Monthly Trend ──
                    if (_stats!.monthlyTrend.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      const Text(
                        "Monthly Trend (Last 6 Months)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkText,
                        ),
                      ),
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
                          children: _stats!.monthlyTrend.map((m) {
                            final month = m['month'] ?? '';
                            final bookings = m['bookings'] ?? 0;
                            final earnings = m['earnings'] ?? 0.0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      month.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.grey,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "$bookings bookings",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "NPR ${earnings.toStringAsFixed(0)}",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProgressRow(String label, int value, int total, Color color) {
    final pct = total > 0 ? (value / total * 100).round() : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              "$value ($pct%)",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? value / total : 0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppTheme.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
