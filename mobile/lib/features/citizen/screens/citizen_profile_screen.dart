import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../shared/theme/app_theme.dart';

class CitizenProfileScreen extends StatelessWidget {
  const CitizenProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final user = appState.currentUser!;

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text("My Profile"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.deepBlue.withValues(alpha: 0.1),
              child: Text(user.name[0].toUpperCase(),
                  style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepBlue)),
            ),
            const SizedBox(height: 16),
            Text(user.name,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user.email,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            Text(user.location,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 32),

            _profileTile(Icons.account_balance_wallet, "Wallet",
                "Rs. ${user.walletBalance.toInt()}"),
            _profileTile(Icons.location_on, "Location", user.location),
            _profileTile(Icons.email, "Email", user.email),
            _profileTile(Icons.language, "Language", "Nepali / English"),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  appState.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
                icon: const Icon(Icons.logout, color: AppTheme.crimson),
                label: const Text("Logout",
                    style: TextStyle(color: AppTheme.crimson)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.crimson),
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

  Widget _profileTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.deepBlue, size: 22),
          const SizedBox(width: 14),
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const Spacer(),
          Text(value,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
