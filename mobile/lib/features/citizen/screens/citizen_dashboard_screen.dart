import 'package:flutter/material.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/state/app_state.dart';
import '../../../core/data/mock_data.dart';
import '../widgets/service_icon_card.dart';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});

  @override
  State<CitizenDashboardScreen> createState() => _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen>
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
    final myBookings = MockData.bookings
        .where((b) => b.citizenName == user.name)
        .toList();
    final approvedProviders =
        MockData.providers.where((p) => p.isApproved).toList();

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
                     height: 220,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Namaste, ${user.name}! 🙏",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(color: Colors.white)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.white70, size: 14),
                                    const SizedBox(width: 4),
                                    Text(user.location,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.white70)),
                                  ],
                                ),
                              ],
                            ),
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              backgroundImage: const NetworkImage(
                                  "https://i.pravatar.cc/150?img=12"), // Placeholder or user image
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // ── Wallet Card ──
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Wallet Balance",
                                      style: TextStyle(
                                          color: AppTheme.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text("Rs. ${user.walletBalance.toInt()}",
                                      style: const TextStyle(
                                          color: AppTheme.darkText,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: AppTheme.lightGrey,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("Active Bookings",
                                      style: TextStyle(
                                          color: AppTheme.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${myBookings.where((b) => b.status != 'completed').length}",
                                    style: const TextStyle(
                                        color: AppTheme.deepBlue,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Services Section Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text("Our Services",
                    style: Theme.of(context).textTheme.titleLarge),
              ),
            ),

            // ── Services Grid ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 110, // Responsive grid item width
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final provider = approvedProviders[index];
                    return ServiceIconCard(
                      label: provider.service,
                      icon: _resolveIcon(provider.iconName),
                      color: _resolveColor(provider.service),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/citizen/provider-detail',
                        arguments: provider.id,
                      ),
                    );
                  },
                  childCount: approvedProviders.take(8).length,
                ),
              ),
            ),

            // ── Upcoming Bookings Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Upcoming Bookings",
                        style: Theme.of(context).textTheme.titleLarge),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/citizen/bookings'),
                      child: const Text("See All"),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bookings List ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final booking = myBookings
                        .where((b) => b.status != 'completed')
                        .toList()[index];
                    return _buildBookingTile(booking);
                  },
                  childCount: myBookings
                      .where((b) => b.status != 'completed')
                      .length,
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingTile(dynamic b) {
    Color statusColor;
    switch (b.status) {
      case 'confirmed':
        statusColor = AppTheme.success;
        break;
      case 'pending':
        statusColor = AppTheme.warning;
        break;
      default:
        statusColor = AppTheme.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_month_rounded, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.serviceName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.darkText)),
                const SizedBox(height: 4),
                Text(b.providerName,
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(b.date,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
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
        return AppTheme.success;
      default:
        return AppTheme.deepBlue;
    }
  }
}
