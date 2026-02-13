import 'package:flutter/material.dart';
import '../../../core/models/api_models.dart';
import '../../../core/services/course_service.dart';
import '../../../shared/theme/app_theme.dart';

class GovTrainingManagementScreen extends StatefulWidget {
  const GovTrainingManagementScreen({super.key});

  @override
  State<GovTrainingManagementScreen> createState() =>
      _GovTrainingManagementScreenState();
}

class _GovTrainingManagementScreenState
    extends State<GovTrainingManagementScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final CourseService _courseService = CourseService();
  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    final courses = await _courseService.getCourses();
    if (mounted) {
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showCourseDialog({Course? existing}) async {
    final titleCtl = TextEditingController(text: existing?.title ?? '');
    final descCtl = TextEditingController(text: existing?.description ?? '');
    final startCtl = TextEditingController(text: existing?.startDate ?? '');
    final endCtl = TextEditingController(text: existing?.endDate ?? '');
    final capCtl = TextEditingController(
      text: existing != null ? '${existing.capacity}' : '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing != null ? 'Edit Course' : 'New Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: startCtl,
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  hintText: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: endCtl,
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  hintText: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: capCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacity'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (titleCtl.text.trim().isEmpty) return;
              if (existing != null) {
                await _courseService.updateCourse(existing.id, {
                  'title': titleCtl.text.trim(),
                  'description': descCtl.text.trim(),
                  'start_date': startCtl.text.trim().isNotEmpty
                      ? startCtl.text.trim()
                      : null,
                  'end_date': endCtl.text.trim().isNotEmpty
                      ? endCtl.text.trim()
                      : null,
                  'capacity':
                      int.tryParse(capCtl.text.trim()) ?? existing.capacity,
                });
              } else {
                await _courseService.createCourse(
                  title: titleCtl.text.trim(),
                  description: descCtl.text.trim(),
                  startDate: startCtl.text.trim(),
                  endDate: endCtl.text.trim(),
                  capacity: int.tryParse(capCtl.text.trim()) ?? 30,
                );
              }
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: Text(existing != null ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
    if (saved == true) _loadCourses();
  }

  Future<void> _deleteCourse(Course c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Delete "${c.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.crimson),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await _courseService.deleteCourse(c.id);
      if (ok) _loadCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = _courses;

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
                "Training Management",
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
                    colors: [AppTheme.deepBlue, Colors.purple],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (courses.isEmpty)
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
                      child: Icon(
                        Icons.school,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No training programs",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((ctx, index) {
                  final c = courses[index];
                  final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Interval(
                        (index / courses.length) * 0.5,
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
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.school,
                                      color: Colors.purple,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppTheme.darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 14,
                                              color: AppTheme.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              c.duration,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppTheme.grey,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.bar_chart_rounded,
                                              size: 14,
                                              color: AppTheme.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              c.status.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppTheme.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.deepBlue.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          "${c.enrolledCount}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppTheme.deepBlue,
                                          ),
                                        ),
                                        Text(
                                          "students",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.offWhite,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: AppTheme.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    c.startDate != null
                                        ? "${c.startDate} → ${c.endDate ?? '?'}"
                                        : "Dates TBD",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.darkText,
                                    ),
                                  ),
                                ],
                              ),
                              if (c.description.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  c.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.grey,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _showCourseDialog(existing: c),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: AppTheme.deepBlue,
                                      ),
                                      label: const Text(
                                        "Edit",
                                        style: TextStyle(
                                          color: AppTheme.deepBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: AppTheme.deepBlue,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _deleteCourse(c),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: AppTheme.crimson,
                                      ),
                                      label: const Text(
                                        "Delete",
                                        style: TextStyle(
                                          color: AppTheme.crimson,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: AppTheme.crimson,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: courses.length),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCourseDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "New Course",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.crimson,
        elevation: 4,
      ),
    );
  }
}
