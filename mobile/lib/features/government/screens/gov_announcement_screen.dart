import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../shared/theme/app_theme.dart';

class GovAnnouncementScreen extends StatefulWidget {
  const GovAnnouncementScreen({super.key});

  @override
  State<GovAnnouncementScreen> createState() => _GovAnnouncementScreenState();
}

class _GovAnnouncementScreenState extends State<GovAnnouncementScreen> {
  final List<Announcement> _announcements = List.from(MockData.recentAnnouncements);

  void _showCreateDialog() {
    String title = '';
    String content = '';
    String target = 'all';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create Broadcast", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
            const SizedBox(height: 20),
            TextField(
              onChanged: (val) => title = val,
              decoration: const InputDecoration(labelText: "Announcement Title"),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (val) => content = val,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Detailed Content"),
            ),
            const SizedBox(height: 16),
            const Text("Target Audience:", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                _targetChip('all', target, (val) => setState(() => target = val)),
                const SizedBox(width: 8),
                _targetChip('citizens', target, (val) => setState(() => target = val)),
                const SizedBox(width: 8),
                _targetChip('providers', target, (val) => setState(() => target = val)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (title.isNotEmpty && content.isNotEmpty) {
                    setState(() {
                      _announcements.insert(0, Announcement(
                        id: 'a${DateTime.now().millisecondsSinceEpoch}',
                        title: title,
                        content: content,
                        date: '2026-02-13',
                        target: target,
                      ));
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Broadcast Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _targetChip(String label, String current, Function(String) onSelect) {
    final isSelected = current == label;
    return ChoiceChip(
      label: Text(label.toUpperCase(), style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.teal)),
      selected: isSelected,
      selectedColor: Colors.teal,
      onSelected: (val) => onSelect(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.teal,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("System Announcements", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final announcement = _announcements[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.teal.withValues(alpha: 0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.campaign_rounded, color: Colors.teal, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(announcement.title, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkText)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(announcement.content, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text("TO: ${announcement.target.toUpperCase()}", 
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                              ),
                              const Spacer(),
                              Text(announcement.date, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _announcements.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Create Broadcast", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
