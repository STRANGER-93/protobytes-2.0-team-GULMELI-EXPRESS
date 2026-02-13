import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/user_role.dart';
import '../../../shared/theme/app_theme.dart';

class GovUserManagementScreen extends StatefulWidget {
  const GovUserManagementScreen({super.key});

  @override
  State<GovUserManagementScreen> createState() => _GovUserManagementScreenState();
}

class _GovUserManagementScreenState extends State<GovUserManagementScreen> {
  String _searchQuery = '';
  // Local state for toggling status (mock)
  final Map<String, bool> _userStatus = {
    for (var u in MockData.allUsers) u.id: true
  };

  @override
  Widget build(BuildContext context) {
    final users = MockData.allUsers.where((u) => 
      u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      u.email.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppTheme.deepBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("User Directory", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.deepBlue, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Search name, email or role...",
                  prefixIcon: const Icon(Icons.search, color: AppTheme.deepBlue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = users[index];
                  final isActive = _userStatus[user.id] ?? true;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                    ),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: (user.role == UserRole.government ? Colors.amber : AppTheme.deepBlue).withValues(alpha: 0.1),
                        child: Icon(
                          user.role == UserRole.government ? Icons.admin_panel_settings : Icons.person,
                          color: user.role == UserRole.government ? Colors.orange : AppTheme.deepBlue,
                          size: 20,
                        ),
                      ),
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                      subtitle: Text(user.role.name.toUpperCase(), 
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                      trailing: Switch.adaptive(
                        value: isActive,
                        activeTrackColor: AppTheme.success.withValues(alpha: 0.5),
                        activeThumbColor: AppTheme.success,
                        onChanged: (val) => setState(() => _userStatus[user.id] = val),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        const Divider(),
                        _userDetailRow(Icons.email_outlined, "Email", user.email),
                        const SizedBox(height: 8),
                        _userDetailRow(Icons.location_on_outlined, "Location", user.location),
                        if (user.role == UserRole.citizen) ...[
                          const SizedBox(height: 8),
                          _userDetailRow(Icons.account_balance_wallet_outlined, "Wallet Balance", "Rs. ${user.walletBalance}"),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.history_rounded, size: 16),
                              label: const Text("View Activity Log"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.crimson.withValues(alpha: 0.1),
                                foregroundColor: AppTheme.crimson,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Reset Password"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                childCount: users.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _userDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.grey)),
        Text(value, style: const TextStyle(fontSize: 12, color: AppTheme.darkText)),
      ],
    );
  }
}
