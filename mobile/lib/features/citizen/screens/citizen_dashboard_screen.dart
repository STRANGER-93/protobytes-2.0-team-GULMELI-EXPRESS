import 'package:flutter/material.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/state/app_state.dart';
import '../../../core/data/mock_data.dart';
import '../widgets/service_icon_card.dart';

class CitizenDashboardScreen extends StatelessWidget {
  const CitizenDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppStateProvider.of(context).currentUser!;
    final myBookings = MockData.bookings
        .where((b) => b.citizenName == user.name)
        .toList();
    final approvedProviders =
        MockData.providers.where((p) => p.isApproved).toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50.withValues(alpha: 0.8),
              Colors.white,
              Colors.purple.shade50.withValues(alpha: 0.5),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      const Text(
                        "JanSewa",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none,
                            color: Colors.black87),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // ── Greeting ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            AppTheme.deepBlue.withValues(alpha: 0.1),
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.deepBlue),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Namaste, ${user.name}! 🙏",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(user.location,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Wallet & Bookings Card ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.deepBlue, AppTheme.crimson],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepBlue.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Wallet",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                              Text("Rs. ${user.walletBalance.toInt()}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.white30,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text("Active Bookings",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                              Text(
                                "${myBookings.where((b) => b.status != 'completed').length}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Services Grid ──
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Verified Local Services",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87)),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: approvedProviders.take(6).map((p) {
                      return ServiceIconCard(
                        label: p.service,
                        icon: _resolveIcon(p.iconName),
                        color: _resolveColor(p.service),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/citizen/provider-detail',
                          arguments: p.id,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Upcoming Bookings ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Upcoming Bookings",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, '/citizen/bookings'),
                        child: const Text("See All"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...myBookings
                    .where((b) => b.status != 'completed')
                    .map((b) => _buildBookingTile(b)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingTile(dynamic b) {
    final statusColor = b.status == 'confirmed'
        ? Colors.green
        : b.status == 'pending'
            ? Colors.orange
            : Colors.grey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(Icons.calendar_today, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.serviceName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(b.providerName,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(b.date,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(b.status.toUpperCase(),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _resolveIcon(String name) {
    switch (name) {
      case 'plumbing':
        return Icons.plumbing;
      case 'book':
        return Icons.menu_book;
      case 'content_cut':
        return Icons.content_cut;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'format_paint':
        return Icons.format_paint;
      case 'cleaning_services':
        return Icons.cleaning_services;
      default:
        return Icons.build;
    }
  }

  Color _resolveColor(String service) {
    switch (service) {
      case 'Plumber':
        return Colors.blue;
      case 'Tutor':
        return Colors.purple;
      case 'Tailor':
        return Colors.pink;
      case 'Electrician':
        return Colors.amber.shade700;
      case 'Painter':
        return Colors.teal;
      case 'Cleaner':
        return Colors.green;
      default:
        return Colors.indigo;
    }
  }
}
