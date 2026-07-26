import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../domain/models/listing.dart';
import '../../domain/services/local_ai_service.dart';
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

  String _userNeighborhood = AppConfig.defaultNeighborhoodName;
  String _selectedCategory = 'all';
  ListingType? _selectedTypeFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    // Filter by Search (using LocalAiService natural language search helper)
    if (_searchQuery.trim().isNotEmpty) {
      result = await widget.aiService.searchListings(_searchQuery, result);
    }

    // Sort by createdAt descending
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (mounted) {
      setState(() => _filteredListings = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textScaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: BlinkitHeader(
        currentNeighborhood: _userNeighborhood,
        onLocationChanged: (newLoc) {
          setState(() {
            _userNeighborhood = newLoc;
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
                  // Hero LocalHive Express Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF9E6), Color(0xE8F7EEFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: BlinkitTheme.blinkitYellow),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: BlinkitTheme.blinkitYellow,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '⚡ 8 MINS LOCAL BOARD',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: BlinkitTheme.blinkitGreen,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$_userNeighborhood Market',
                                    style: TextStyle(
                                      fontSize: textScaler.scale(16),
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_allListings.length} verified listings nearby • 100% Private',
                                    style: TextStyle(
                                      fontSize: textScaler.scale(12),
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Neighborhood Activity Pulse',
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
                              icon: const CircleAvatar(
                                backgroundColor: BlinkitTheme.blinkitGreen,
                                child: Icon(Icons.show_chart, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Search Bar Input
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Semantics(
                        label: 'Search listings by keyword or phrase',
                        textField: true,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            _searchQuery = val;
                            _applyFilters();
                          },
                          decoration: InputDecoration(
                            hintText: "Search 'tiffin', 'tutor', 'books', 'plumber'...",
                            prefixIcon: const Icon(Icons.search, color: BlinkitTheme.blinkitYellow, size: 18),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      _searchQuery = '';
                                      _applyFilters();
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            filled: true,
                            fillColor: isDark ? BlinkitTheme.darkElevated : const Color(0xFFEDF1F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Type Toggle Pills (All / Offers / Requests)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                      child: Row(
                        children: [
                          _buildTypeChip('All', null),
                          const SizedBox(width: 6),
                          _buildTypeChip('📤 Offers', ListingType.offer),
                          const SizedBox(width: 6),
                          _buildTypeChip('📥 Requests', ListingType.request),
                          const Spacer(),
                          // Navigation to Settings
                          Semantics(
                            label: 'App Settings & Security Posture',
                            button: true,
                            child: IconButton(
                              icon: const Icon(Icons.settings, size: 18),
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

                  const SliverToBoxAdapter(child: SizedBox(height: 10)),

                  // Dense 2-Column Listing Card Grid (Blinkit Style with Image Thumbnails)
                  _filteredListings.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🔍', style: TextStyle(fontSize: 40)),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No matching listings found',
                                    style: TextStyle(
                                      fontSize: textScaler.scale(15),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Try adjusting your search or category filter for $_userNeighborhood.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: textScaler.scale(12),
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.72,
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
      floatingActionButton: Semantics(
        label: 'Create new listing or request in $_userNeighborhood',
        button: true,
        child: SizedBox(
          width: 110,
          height: 44,
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
      ),
    );
  }

  Widget _buildTypeChip(String label, ListingType? type) {
    final isSelected = _selectedTypeFilter == type;
    return Semantics(
      label: 'Filter by $label',
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: () {
          setState(() => _selectedTypeFilter = type);
          _applyFilters();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? BlinkitTheme.blinkitGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? BlinkitTheme.blinkitGreen : Colors.grey.withOpacity(0.4),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }
}
