import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../shared/theme/app_theme.dart';

class GovTrainingManagementScreen extends StatelessWidget {
  const GovTrainingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = MockData.courses;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text("Training Management")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Add course — coming with backend integration"),
              backgroundColor: AppTheme.deepBlue,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("New Course"),
        backgroundColor: AppTheme.crimson,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (ctx, i) {
          final c = courses[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.school,
                            color: Colors.purple, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                            Text("${c.duration} • ${c.level}",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("${c.enrolledCount}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          Text("enrolled",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Instructor: ${c.instructor}",
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade700)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text("Edit"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text("Remove"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
