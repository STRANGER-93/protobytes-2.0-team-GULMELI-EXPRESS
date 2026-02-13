import 'package:flutter/material.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/models/api_models.dart';
import '../../../shared/theme/app_theme.dart';

class GovBookingManagementScreen extends StatefulWidget {
  const GovBookingManagementScreen({super.key});

  @override
  State<GovBookingManagementScreen> createState() => _GovBookingManagementScreenState();
}

class _GovBookingManagementScreenState extends State<GovBookingManagementScreen> {
  final BookingService _bookingService = BookingService();
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String _activeStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final results = await _bookingService.fetchBookings();
    setState(() {
      _bookings = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Booking> filtered = _activeStatus == 'All' 
        ? _bookings 
        : _bookings.where((b) => b.status.toUpperCase() == _activeStatus.toUpperCase()).toList();

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120, pinned: true,
              backgroundColor: AppTheme.deepBlue,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text("Booking Registry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                background: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.deepBlue, Colors.teal]))),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildFilters(),
            ),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (filtered.isEmpty)
              const SliverFillRemaining(child: Center(child: Text("No bookings recorded")))
            else
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildBookingCard(filtered[i]),
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'].map((s) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(s),
            selected: _activeStatus == s,
            onSelected: (v) => setState(() => _activeStatus = s),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildBookingCard(Booking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(b.skillCategory, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _statusBadge(b.status),
            ],
          ),
          const Divider(height: 24),
          _infoRow(Icons.person, "Citizen", b.citizenName),
          _infoRow(Icons.store, "Provider", b.providerName),
          _infoRow(Icons.payments, "Amount", "NPR ${b.amount}"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: AppTheme.grey),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontSize: 13, color: AppTheme.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
