import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/state/app_state.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/api_models.dart';
import '../widgets/service_icon_card.dart';
import '../../../l10n/generated/app_localizations.dart';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});

  @override
  State<CitizenDashboardScreen> createState() => _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AppLocalizations l10n;
  late AnimationController _controller;
  bool _isLoading = false;
  List<Booking> _upcomingBookings = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _controller.forward();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Simulate API call or fetch from mock
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _upcomingBookings = MockData.bookings
          .map((b) => Booking(
                id: int.tryParse(b.id) ?? 0,
                providerName: b.providerName,
                citizenName: b.citizenName,
                service: b.serviceName,
                status: b.status,
                paymentStatus: 'pending',
                amount: 500,
                scheduledTime: b.date,
              ))
          .toList();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    l10n = AppLocalizations.of(context)!;
    final appState = AppStateProvider.of(context);
    final user = appState.currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    final isProvider = appState.isProviderMode;

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // Custom App Bar / Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 60, 28, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isProvider 
                      ? [AppTheme.success, Colors.teal] 
                      : [AppTheme.deepBlue, AppTheme.crimson],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${l10n.namaste},",
                              style: GoogleFonts.mukta(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              user.name,
                              style: GoogleFonts.mukta(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: Text('🇳🇵', style: TextStyle(fontSize: 24)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Stats Row
                    Row(
                      children: [
                        _buildHeaderStat(
                          isProvider ? l10n.tasksDone : l10n.bookings, 
                          isProvider ? "12" : "${_upcomingBookings.length}", 
                          Icons.calendar_month
                        ),
                        const SizedBox(width: 16),
                        _buildHeaderStat(
                          l10n.wallet, 
                          "Rs. ${user.walletBalance.toInt()}", 
                          Icons.account_balance_wallet
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            SliverPadding(
              padding: const EdgeInsets.all(28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionHeader(isProvider ? l10n.jobRequests : l10n.servicesYouNeed),
                  const SizedBox(height: 16),
                  
                  // Category Grid
                  if (!isProvider) _buildServiceCategories(),
                  if (isProvider) _buildProviderStats(),

                  const SizedBox(height: 32),
                  _buildSectionHeader(isProvider ? l10n.activeJobs : l10n.upcomingBookings),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_upcomingBookings.isEmpty)
                    _buildEmptyState(l10n)
                  else
                    ..._upcomingBookings.take(3).map((b) => _buildBookingTile(b, isHirer: !isProvider)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.mukta(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.darkText,
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCategories() {
    final categories = [
      {'name': l10n.plumber, 'icon': Icons.plumbing, 'color': Colors.blue},
      {'name': l10n.electrician, 'icon': Icons.electrical_services, 'color': Colors.orange},
      {'name': l10n.tutor, 'icon': Icons.book, 'color': Colors.purple},
      {'name': l10n.painter, 'icon': Icons.format_paint, 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return ServiceIconCard(
          label: cat['name'] as String,
          icon: cat['icon'] as IconData,
          color: cat['color'] as Color,
          onTap: () => Navigator.pushNamed(context, '/citizen/providers'),
        );
      },
    );
  }

  Widget _buildProviderStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(l10n.completed, "45", Colors.green),
              _buildStatItem(l10n.rating, "4.9", Colors.amber),
              _buildStatItem(l10n.earned, "Rs. 12k", Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            l10n.noUpcomingBookings,
            style: const TextStyle(color: AppTheme.grey, fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }

  Widget _buildBookingTile(Booking b, {required bool isHirer}) {
    Color statusColor;
    switch (b.status.toLowerCase()) {
      case 'confirmed':
        statusColor = AppTheme.success;
        break;
      case 'pending':
        statusColor = AppTheme.warning;
        break;
      default:
        statusColor = AppTheme.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_month_rounded, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.service,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.darkText)),
                const SizedBox(height: 4),
                Text(isHirer ? b.providerName : b.citizenName,
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(b.scheduledTime,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(b.status.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
