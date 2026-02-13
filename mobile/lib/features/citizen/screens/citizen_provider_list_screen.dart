import 'package:flutter/material.dart';
import '../../../core/services/provider_service.dart';
import '../../../core/models/api_models.dart' as api;
import '../../../shared/theme/app_theme.dart';

class CitizenProviderListScreen extends StatefulWidget {
  const CitizenProviderListScreen({super.key});

  @override
  State<CitizenProviderListScreen> createState() =>
      _CitizenProviderListScreenState();
}

class _CitizenProviderListScreenState extends State<CitizenProviderListScreen> {
  final ProviderService _providerService = ProviderService();
  final _searchController = TextEditingController();

  List<api.ProviderProfile> _providers = [];
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    setState(() => _isLoading = true);
    final results = await _providerService.getProviders(
      search: _searchController.text.isEmpty ? null : _searchController.text,
      skill: _selectedCategory,
    );
    setState(() {
      _providers = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.deepBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.deepBlue, AppTheme.crimson],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _fetchProviders(),
                    decoration: InputDecoration(
                      hintText: "Search for professionals...",
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.deepBlue,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              centerTitle: true,
              title: const Text(
                "Find Professionals",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Category Selector
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                children: [
                  _categoryChip("All", null),
                  _categoryChip("Electrician", "electrician"),
                  _categoryChip("Plumber", "plumber"),
                  _categoryChip("Carpenter", "carpenter"),
                  _categoryChip("Mason", "mason"),
                  _categoryChip("Painter", "painter"),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_providers.isEmpty)
            _buildEmptyState()
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _providerCard(_providers[index]),
                  childCount: _providers.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, String? value) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() => _selectedCategory = val ? value : null);
          _fetchProviders();
        },
        selectedColor: AppTheme.deepBlue,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.darkText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isSelected ? 4 : 0,
      ),
    );
  }

  Widget _providerCard(api.ProviderProfile provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/citizen/provider-detail',
          arguments: provider.id.toString(),
        ),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'provider_${provider.id}',
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: AppTheme.offWhite,
                  child: Text(
                    provider.name.isNotEmpty ? provider.name[0] : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            provider.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (provider.municipalityVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      provider.primarySkill,
                      style: const TextStyle(
                        color: AppTheme.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        Text(
                          " ${provider.avgRating} ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "(${provider.jobsCompleted} jobs)",
                          style: const TextStyle(
                            color: AppTheme.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "No professionals found",
            style: TextStyle(color: AppTheme.grey, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Try changing your search or filters",
            style: TextStyle(color: AppTheme.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
