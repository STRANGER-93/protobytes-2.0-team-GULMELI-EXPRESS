import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../shared/theme/app_theme.dart';

class CitizenCourseListScreen extends StatelessWidget {
  const CitizenCourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = MockData.courses;

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text("Training Programs"),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final c = courses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                '/citizen/course-detail',
                arguments: c.id,
              ),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.deepBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.school,
                          color: AppTheme.deepBlue, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            "${c.duration} • ${c.level}",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text("${c.enrolledCount}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepBlue)),
                        Text("enrolled",
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
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
