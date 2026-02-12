import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/state/app_state.dart';
import '../../../shared/theme/app_theme.dart';

class CitizenBookingsScreen extends StatefulWidget {
  const CitizenBookingsScreen({super.key});

  @override
  State<CitizenBookingsScreen> createState() => _CitizenBookingsScreenState();
}

class _CitizenBookingsScreenState extends State<CitizenBookingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
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
    final myBookings =
        MockData.bookings.where((b) => b.citizenName == user.name).toList();

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.success,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "My Bookings",
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
                    colors: [AppTheme.success, Colors.teal],
                  ),
                ),
              ),
            ),
          ),
          if (myBookings.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.calendar_today_rounded,
                          size: 48, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 24),
                    Text("No bookings yet",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Text("Your scheduled services will appear here",
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final b = myBookings[index];
                    final statusColor = _statusColor(b.status);
                    
                    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: Interval(
                          (index / myBookings.length) * 0.5,
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
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.calendar_month_rounded,
                                      color: statusColor, size: 28),
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
                                              fontSize: 14,
                                              color: AppTheme.grey,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time_rounded,
                                              size: 14, color: AppTheme.grey),
                                          const SizedBox(width: 4),
                                          Text(b.date,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme.grey)),
                                          const SizedBox(width: 12),
                                          Icon(Icons.payments_outlined,
                                              size: 14, color: AppTheme.grey),
                                          const SizedBox(width: 4),
                                          Text("Rs. ${b.amount.toInt()}",
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: statusColor.withValues(alpha: 0.2)),
                                  ),
                                  child: Text(
                                    b.status.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        color: statusColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: myBookings.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppTheme.success;
      case 'pending':
        return AppTheme.warning;
      case 'completed':
        return AppTheme.deepBlue;
      case 'cancelled':
        return AppTheme.crimson;
      default:
        return AppTheme.grey;
    }
  }
}
