import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/user_role.dart';
import '../../../shared/theme/app_theme.dart';

class CitizenCourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CitizenCourseDetailScreen({super.key, required this.courseId});

  @override
  State<CitizenCourseDetailScreen> createState() =>
      _CitizenCourseDetailScreenState();
}

class _CitizenCourseDetailScreenState extends State<CitizenCourseDetailScreen> {
  late Course _course;
  bool _enrolled = false;

  @override
  void initState() {
    super.initState();
    _course = MockData.courses.firstWhere(
      (c) => c.id == widget.courseId,
      orElse: () => MockData.courses.first,
    );
  }

  void _enroll() {
    setState(() => _enrolled = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Enrolled in ${_course.title}! 🎉"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(title: Text(_course.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.deepBlue, AppTheme.crimson],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.school, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  Text(_course.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("${_course.duration} • ${_course.level}",
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Details
            _infoRow(Icons.person, "Instructor", _course.instructor),
            _infoRow(Icons.timer, "Duration", _course.duration),
            _infoRow(Icons.signal_cellular_alt, "Level", _course.level),
            _infoRow(Icons.people, "Enrolled",
                "${_course.enrolledCount} students"),
            const SizedBox(height: 20),

            const Text("Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(_course.description,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
            const SizedBox(height: 30),

            // Enroll button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _enrolled ? null : _enroll,
                icon: Icon(_enrolled ? Icons.check : Icons.school),
                label: Text(_enrolled ? "Enrolled ✓" : "Enroll Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _enrolled ? Colors.green : AppTheme.crimson,
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
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15)),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}
