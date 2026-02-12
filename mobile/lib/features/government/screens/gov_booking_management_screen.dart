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
    extends State<GovBookingManagementScreen> {
  String _filterStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final allBookings = MockData.bookings;
    final filtered = _filterStatus == 'All'
        ? allBookings
        : allBookings.where((b) => b.status == _filterStatus.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text("Booking Management")),
      body: Column(
        children: [
          // ── Filter Chips ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled']
                  .map((status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: _filterStatus == status,
                          selectedColor: AppTheme.deepBlue,
                          labelStyle: TextStyle(
                            color: _filterStatus == status
                                ? Colors.white
                                : Colors.black87,
                          ),
                          onSelected: (_) =>
                              setState(() => _filterStatus = status),
                        ),
                      ))
                  .toList(),
            ),
          ),

          // ── Table-like List ──
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("No bookings found"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final b = filtered[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(b.serviceName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                  _statusBadge(b.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _row("Citizen", b.citizenName),
                              _row("Provider", b.providerName),
                              _row("Date", b.date),
                              _row("Amount", "Rs. ${b.amount.toInt()}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500))),
          Expanded(
              child:
                  Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = {
      'pending': Colors.orange,
      'confirmed': Colors.green,
      'completed': Colors.blue,
      'cancelled': Colors.red,
    }[status] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
