import 'package:flutter/material.dart';
import '../../domain/models/category.dart';
import '../../domain/models/listing.dart';
import '../../domain/services/local_ai_service.dart';
import '../../domain/services/location_service.dart';
import '../../repository/listing_repository.dart';
import '../theme/blinkit_theme.dart';
import '../widgets/blinkit_header.dart';
import '../widgets/category_scroll_bar.dart';
import '../widgets/listing_card.dart';
import 'create_screen.dart';
import 'details_screen.dart';
import 'pulse_screen.dart';
import 'settings_screen.dart';

class FeedScreen extends StatefulWidget {
  final ListingRepository repository;
  final LocalAiService aiService;

  const FeedScreen({
    super.key,
    required this.repository,
    required this.aiService,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Listing> _allListings = [];
  List<Listing> _filteredListings = [];
  bool _isLoading = true;

  String _userLocation = 'Current Location';
  String _selectedCategory = 'all';
  ListingType? _selectedTypeFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initLocationAndListings();
  }

  Future<void> _initLocationAndListings() async {
    final savedLoc = await LocationService.getSavedLocation();
    if (savedLoc == 'Detecting location...') {
      final detected = await LocationService.detectCurrentLocation();
      if (mounted) setState(() => _userLocation = detected);
    } else {
      if (mounted) setState(() => _userLocation = savedLoc);
    }
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    final listings = await widget.repository.getAll();
    setState(() {
      _allListings = listings;
      _isLoading = false;
    });
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    List<Listing> result = List.from(_allListings);

    // Filter by Type (Offer / Request)
    if (_selectedTypeFilter != null) {
      result = result.where((l) => l.type == _selectedTypeFilter).toList();
    }

    // Filter by Category
    if (_selectedCategory != 'all') {
      result = result.where((l) => l.categoryId == _selectedCategory).toList();
    }

    // Filter by Search
    if (_searchQuery.trim().isNotEmpty) {
      result = await widget.aiService.searchListings(_searchQuery, result);
    }

    // Sort by createdAt descending
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (mounted) {
      setState(() => _filteredListings = result);
    }
  }

  int get _savedCount => _allListings.where((l) => l.status == ListingStatus.saved).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive columns (Matching Image 3 desktop grid vs mobile grid)
    final crossAxisCount = screenWidth > 1100
        ? 5
        : screenWidth > 800
            ? 4
            : screenWidth > 550
                ? 3
                : 2;

    return Scaffold(
      appBar: BlinkitHeader(
        currentNeighborhood: _userLocation,
        savedCount: _savedCount,
        onSearchChanged: (val) {
          _searchQuery = val;
          _applyFilters();
        },
        onLocationChanged: (newLoc) {
          setState(() {
            _userLocation = newLoc;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📍 Location updated to $newLoc'),
              backgroundColor: BlinkitTheme.blinkitGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: BlinkitTheme.blinkitGreen))
          : RefreshIndicator(
              onRefresh: _loadListings,
              color: BlinkitTheme.blinkitGreen,
              child: CustomScrollView(
                slivers: [
                  // Category Chips & Filter Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          _buildTypeChip('All', null),
                          const SizedBox(width: 8),
                          _buildTypeChip('📤 Offers', ListingType.offer),
                          const SizedBox(width: 8),
                          _buildTypeChip('📥 Requests', ListingType.request),
                          const Spacer(),
                          // Neighborhood Pulse Analytics
                          IconButton(
                            tooltip: 'Neighborhood Activity Pulse',
                            icon: const Icon(Icons.show_chart, color: BlinkitTheme.blinkitGreen),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PulseScreen(
                                    repository: widget.repository,
                                    aiService: widget.aiService,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Settings
                          IconButton(
                            icon: const Icon(Icons.settings, size: 20),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SettingsScreen(
                                    repository: widget.repository,
                                    aiService: widget.aiService,
                                  ),
                                ),
                              );
                              _loadListings();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Category Scroll Bar
                  SliverToBoxAdapter(
                    child: CategoryScrollBar(
                      selectedCategoryId: _selectedCategory,
                      onSelectCategory: (catId) {
                        setState(() => _selectedCategory = catId);
                        _applyFilters();
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // Category Section Header (Matching Image 3: Category Title + "see all")
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategory == 'all'
                                ? 'Nearby Items & Services in $_userLocation'
                                : '${ListingCategory.getById(_selectedCategory).icon} ${ListingCategory.getById(_selectedCategory).name}',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'see all (${_filteredListings.length})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: BlinkitTheme.blinkitGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Compact Product Grid (Matching Image 3 Blinkit reference grid)
                  _filteredListings.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🔍', style: TextStyle(fontSize: 44)),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No matching listings found',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Try adjusting your search or location for $_userLocation.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.68, // Compact vertical card ratio
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final listing = _filteredListings[index];
                                return ListingCard(
                                  listing: listing,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetailsScreen(
                                          listingId: listing.id,
                                          repository: widget.repository,
                                          aiService: widget.aiService,
                                        ),
                                      ),
                                    );
                                    _loadListings();
                                  },
                                );
                              },
                              childCount: _filteredListings.length,
                            ),
                          ),
                        ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
      // Prominent Floating Action Button "+ Post"
      floatingActionButton: SizedBox(
        width: 110,
        height: 46,
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateScreen(
                  repository: widget.repository,
                  aiService: widget.aiService,
                ),
              ),
            );
            _loadListings();
          },
          icon: const Icon(Icons.add, fontWeight: FontWeight.bold, size: 18),
          label: const Text(
            '+ Post',
            style: TextStyle(
              fontFamily: 'Sora',
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, ListingType? type) {
    final isSelected = _selectedTypeFilter == type;
    return InkWell(
      onTap: () {
        setState(() => _selectedTypeFilter = type);
        _applyFilters();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? BlinkitTheme.blinkitGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? BlinkitTheme.blinkitGreen : Colors.grey.withOpacity(0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}
