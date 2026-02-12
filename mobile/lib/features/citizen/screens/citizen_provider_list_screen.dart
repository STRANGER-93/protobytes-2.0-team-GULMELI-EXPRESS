import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../shared/theme/app_theme.dart';

class CitizenProviderListScreen extends StatelessWidget {
  const CitizenProviderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = MockData.providers.where((p) => p.isApproved).toList();

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text("Service Providers"),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: providers.length,
        itemBuilder: (context, index) {
          final p = providers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                '/citizen/provider-detail',
                arguments: p.id,
              ),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          AppTheme.crimson.withValues(alpha: 0.1),
                      child: Text(p.name[0],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.crimson,
                              fontSize: 18)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                          Text("${p.service} • ${p.location}",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text("${p.rating}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
