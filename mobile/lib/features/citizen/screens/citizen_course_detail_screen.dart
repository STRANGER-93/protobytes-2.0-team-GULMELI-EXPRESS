import 'package:flutter/material.dart';
import '../../../core/services/course_service.dart';
import '../../../core/services/enrollment_service.dart';
import '../../../core/models/api_models.dart' as api;
import '../../../shared/theme/app_theme.dart';

class CitizenCourseDetailScreen extends StatefulWidget {
  const CitizenCourseDetailScreen({super.key});

  @override
  State<CitizenCourseDetailScreen> createState() =>
      _CitizenCourseDetailScreenState();
}

class _CitizenCourseDetailScreenState extends State<CitizenCourseDetailScreen>
    with SingleTickerProviderStateMixin {
  final CourseService _courseService = CourseService();
  final EnrollmentService _enrollmentService = EnrollmentService();
  api.Course? _course;
  bool _enrolled = false;
  bool _isLoading = true;
  bool _isEnrolling = false;
  late AnimationController _controller;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is int) {
        _loadCourse(arguments);
      } else if (arguments is String) {
        _loadCourse(int.tryParse(arguments) ?? 0);
      }
      _isInitialized = true;
    }
  }

  Future<void> _loadCourse(int id) async {
    setState(() => _isLoading = true);
    final course = await _courseService.getCourseDetail(id);
    if (course != null) {
      setState(() {
        _course = course;
        _isLoading = false;
      });
    } else {
      // Fallback: try from list
      final courses = await _courseService.getCourses();
      final match = courses.where((c) => c.id == id);
      setState(() {
        _course = match.isNotEmpty ? match.first : null;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleEnroll() async {
    if (_course == null) return;
    setState(() => _isEnrolling = true);
    final result = await _enrollmentService.enrollInCourse(_course!.id);
    if (!mounted) return;
    setState(() {
      _isEnrolling = false;
      if (result != null) _enrolled = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result != null
              ? "Enrolled in ${_course!.title}!"
              : "Enrollment failed. Please try again.",
        ),
        backgroundColor: result != null ? AppTheme.success : AppTheme.crimson,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_course == null) {
      return const Scaffold(body: Center(child: Text("Course not found")));
    }
    final c = _course!;

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.deepBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                c.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.deepBlue, Colors.purple],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.school,
                          size: 80,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            c.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "About this Course",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      c.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Stats Grid
                _buildAnimatedSection(
                  0.2,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat(
                        Icons.timer_outlined,
                        "Duration",
                        c.duration,
                        Colors.blue,
                      ),
                      _buildStat(
                        Icons.people_outline,
                        "Enrolled",
                        "${c.enrolledCount}/${c.capacity}",
                        Colors.orange,
                      ),
                      _buildStat(
                        Icons.event_available,
                        "Slots Left",
                        "${c.availableSlots}",
                        c.isFull ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Course Details Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Course Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _detailRow(
                            Icons.calendar_today,
                            "Start Date",
                            c.startDate ?? 'TBD',
                          ),
                          const Divider(),
                          _detailRow(
                            Icons.event,
                            "End Date",
                            c.endDate ?? 'TBD',
                          ),
                          const Divider(),
                          _detailRow(
                            Icons.group,
                            "Capacity",
                            "${c.capacity} students",
                          ),
                          const Divider(),
                          _detailRow(Icons.info_outline, "Status", c.status),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 100), // Spacing for bottom button
              ]),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: FadeTransition(
          opacity: _controller,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (_enrolled || _isEnrolling || c.isFull)
                  ? null
                  : _handleEnroll,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.isFull ? Colors.grey : AppTheme.deepBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _enrolled
                    ? AppTheme.success.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.3),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isEnrolling
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _enrolled
                              ? Icons.check_circle
                              : c.isFull
                              ? Icons.block
                              : Icons.school_outlined,
                          color: _enrolled ? AppTheme.success : Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _enrolled
                              ? "ALREADY ENROLLED"
                              : c.isFull
                              ? "COURSE FULL"
                              : "ENROLL NOW",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(double start, Widget child) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, start + 0.4, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.deepBlue, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppTheme.grey),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
