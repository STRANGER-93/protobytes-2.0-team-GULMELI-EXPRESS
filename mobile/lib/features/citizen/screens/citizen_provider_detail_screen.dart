import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../shared/theme/app_theme.dart';

class CitizenProviderDetailScreen extends StatelessWidget {
  final String providerId;

  const CitizenProviderDetailScreen({super.key, required this.providerId});

  @override
  Widget build(BuildContext context) {
    final provider = MockData.providers.firstWhere(
      (p) => p.id == providerId,
      orElse: () => MockData.providers.first,
    );

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(title: Text(provider.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.crimson, Colors.orange.shade700],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Text(provider.name[0],
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.crimson)),
                  ),
                  const SizedBox(height: 12),
                  Text(provider.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  Text(provider.service,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 15)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text("${provider.rating}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _infoRow(Icons.location_on, "Location", provider.location),
            _infoRow(Icons.phone, "Phone", provider.phone),
            _infoRow(Icons.verified, "Status",
                provider.isApproved ? "Verified ✓" : "Pending"),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Booking request sent to ${provider.name}! 📞"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text("Book Service"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text("Contact via WhatsApp"),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.deepBlue),
          const SizedBox(width: 10),
          Text("$label: ",
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          Expanded(
              child: Text(value,
                  style:
                      TextStyle(fontSize: 15, color: Colors.grey.shade700))),
        ],
      ),
    );
  }
}
