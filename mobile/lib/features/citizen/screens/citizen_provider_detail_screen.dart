import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/provider_service.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/models/api_models.dart' as api;
import '../../../shared/theme/app_theme.dart';

class CitizenProviderDetailScreen extends StatefulWidget {
  const CitizenProviderDetailScreen({super.key});

  @override
  State<CitizenProviderDetailScreen> createState() => _CitizenProviderDetailScreenState();
}

class _CitizenProviderDetailScreenState extends State<CitizenProviderDetailScreen> {
  final ProviderService _providerService = ProviderService();
  
  api.ProviderProfile? _provider;
  List<api.Review> _reviews = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_provider == null) {
      final arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments is String) {
        _loadData(int.parse(arguments));
      } else if (arguments is int) {
        _loadData(arguments);
      }
    }
  }

  Future<void> _loadData(int id) async {
    setState(() => _isLoading = true);
    final provider = await _providerService.getProviderDetail(id);
    final reviews = await _providerService.getProviderReviews(id);
    setState(() {
      _provider = provider;
      _reviews = reviews;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_provider == null) {
      return const Scaffold(body: Center(child: Text("Provider not found")));
    }

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStats(),
                _buildBioAndSkills(),
                _buildReviewsHeader(),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildReviewCard(_reviews[index]),
                childCount: _reviews.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomSheet: _buildBottomActionBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppTheme.deepBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'provider_${_provider!.id}',
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.deepBlue, AppTheme.crimson],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                _provider!.name.isNotEmpty ? _provider!.name[0] : '?',
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_provider!.name, style: GoogleFonts.mukta(fontSize: 28, fontWeight: FontWeight.bold)),
                    Text(_provider!.service, style: const TextStyle(fontSize: 16, color: AppTheme.grey)),
                  ],
                ),
              ),
              if (_provider!.isVerified)
                const Icon(Icons.verified, color: Colors.blue, size: 30),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem("Rating", "${_provider!.avgRating} ⭐"),
              _statItem("Jobs", "${_provider!.jobsCompleted}"),
              _statItem("Experience", _provider!.experience),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepBlue)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
      ],
    );
  }

  Widget _buildBioAndSkills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("About", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(_provider!.bio, style: const TextStyle(color: AppTheme.grey, height: 1.5)),
          const SizedBox(height: 20),
          const Text("Skills", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _provider!.skills.map((s) => Chip(
              label: Text(s),
              backgroundColor: AppTheme.offWhite,
              labelStyle: const TextStyle(fontSize: 12),
            )).toList(),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildReviewsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Recent Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("${_reviews.length} reviews", style: const TextStyle(color: AppTheme.grey)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(api.Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.citizenName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(5, (i) => Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: i < review.rating ? Colors.amber : Colors.grey.shade300,
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: const TextStyle(fontSize: 13, color: AppTheme.grey)),
          const SizedBox(height: 4),
          Text(review.createdAt, style: const TextStyle(fontSize: 10, color: AppTheme.lightGrey)),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.deepBlue),
            iconSize: 30,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _showBookingBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Book Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingBottomSheet(provider: _provider!),
    );
  }
}

class _BookingBottomSheet extends StatefulWidget {
  final api.ProviderProfile provider;
  const _BookingBottomSheet({required this.provider});

  @override
  State<_BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<_BookingBottomSheet> {
  final BookingService _bookingService = BookingService();
  bool _isBooking = false;

  Future<void> _handleBook() async {
    setState(() => _isBooking = true);
    final booking = await _bookingService.createBooking(
      providerId: widget.provider.id,
      scheduledTime: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      amount: 500.0,
      serviceDetails: "Standard ${widget.provider.service} request",
    );
    
    if (!mounted) return;
    setState(() => _isBooking = false);
    
    if (booking != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking request sent successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to create booking. Please try again."),
          backgroundColor: AppTheme.crimson,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(30, 30, 30, 40 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Confirm Booking", style: GoogleFonts.mukta(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 20),
          _bookingDetailRow("Professional", widget.provider.name),
          _bookingDetailRow("Service", widget.provider.service),
          _bookingDetailRow("Estimated Price", "Rs. 500"),
          _bookingDetailRow("Date", "Tomorrow"),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isBooking ? null : _handleBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepBlue,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isBooking 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Confirm & Pay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
