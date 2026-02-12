import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../shared/theme/app_theme.dart';

class GovBookingManagementScreen extends StatefulWidget {
  const GovBookingManagementScreen({super.key});

  @override
  State<GovBookingManagementScreen> createState() =>
      _GovBookingManagementScreenState();
}

class _GovBookingManagementScreenState
    extends State<GovBookingManagementScreen>
    with SingleTickerProviderStateMixin {
  String _filterStatus = 'All';
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
    final allBookings = MockData.bookings;
    final filtered = _filterStatus == 'All'
        ? allBookings
        : allBookings
            .where((b) => b.status == _filterStatus.toLowerCase())
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.deepBlue,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "Booking Management",
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
                    colors: [AppTheme.deepBlue, Colors.teal],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  'All',
                  'Pending',
                  'Confirmed',
                  'Completed',
                  'Cancelled'
                ]
                    .map((status) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(status),
                            selected: _filterStatus == status,
                            selectedColor: AppTheme.deepBlue,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                                color: _filterStatus == status
                                    ? Colors.transparent
                                    : Colors.grey.shade300),
                            elevation: _filterStatus == status ? 4 : 0,
                            shadowColor:
                                AppTheme.deepBlue.withValues(alpha: 0.3),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _filterStatus == status
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _filterStatus = status;
                                _controller.reset();
                                _controller.forward();
                              });
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          if (filtered.isEmpty)
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
                      child: Icon(Icons.event_busy_rounded,
                          size: 48, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 16),
                    Text("No bookings found",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) {
                    final b = filtered[index];
                    final animation =
                        Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: Interval(
                          (index / filtered.length) * 0.5,
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
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.1)),
                          ),
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(b.serviceName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: AppTheme.darkText)),
                                      ),
                                      _statusBadge(b.status),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _row(Icons.person_outline, "Citizen",
                                      b.citizenName),
                                  const SizedBox(height: 8),
                                  _row(Icons.storefront_outlined, "Provider",
                                      b.providerName),
                                  const SizedBox(height: 8),
                                  _row(Icons.calendar_today_outlined, "Date",
                                      b.date),
                                  const SizedBox(height: 8),
                                  _row(Icons.payments_outlined, "Amount",
                                      "Rs. ${b.amount.toInt()}"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.grey),
        const SizedBox(width: 8),
        SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.grey,
                    fontWeight: FontWeight.w500))),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = AppTheme.warning;
        break;
      case 'confirmed':
        color = AppTheme.success;
        break;
      case 'completed':
        color = AppTheme.deepBlue;
        break;
      case 'cancelled':
        color = AppTheme.crimson;
        break;
      default:
        color = AppTheme.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: color),
      ),
    );
  }
}
