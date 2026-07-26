import 'package:flutter/material.dart';
import '../../domain/models/category.dart';
import '../../domain/models/listing.dart';
import '../../domain/services/local_ai_service.dart';
import '../../domain/services/location_service.dart';
import '../../repository/listing_repository.dart';
import '../theme/blinkit_theme.dart';
import '../widgets/blinkit_header.dart';
import '../widgets/category_scroll_bar.dart';
import '../widgets/checkout_sheet.dart';
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

  // Service Checkout Cart State
  final Set<String> _cartListingIds = {};

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

  List<Listing> get _selectedCartListings =>
      _allListings.where((l) => _cartListingIds.contains(l.id)).toList();

  void _toggleCart(Listing listing) {
    setState(() {
      if (_cartListingIds.contains(listing.id)) {
        _cartListingIds.remove(listing.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${listing.title}" from Cart'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        _cartListingIds.add(listing.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🛒 Added "${listing.title}" to Cart!'),
            backgroundColor: BlinkitTheme.blinkitGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _openCheckoutModal() {
    if (_cartListingIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty! Tap ADD on any service below to add it to your cart.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => CheckoutSheet(
        selectedListings: _selectedCartListings,
        userLocation: _userLocation,
        onClearCart: () {
          setState(() => _cartListingIds.clear());
        },
        onOrderConfirmed: () {
          _loadListings();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    final crossAxisCount = screenWidth > 1100
        ? 5
        : screenWidth > 800
            ? 4
            : screenWidth > 550
                ? 3
                : 2;

    final childAspectRatio = screenWidth > 800 ? 0.92 : 0.84;

    return Scaffold(
      appBar: BlinkitHeader(
        currentNeighborhood: _userLocation,
        cartCount: _cartListingIds.length,
        onCartTap: _openCheckoutModal,
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
                  // Filter Pills Row
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

                  // Category Section Header (Wrapped with Expanded to prevent text overflow)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedCategory == 'all'
                                  ? 'Nearby Services & Items in $_userLocation'
                                  : '${ListingCategory.getById(_selectedCategory).icon} ${ListingCategory.getById(_selectedCategory).name}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
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

                  // Compact Grid
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
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: childAspectRatio,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final listing = _filteredListings[index];
                                final isAdded = _cartListingIds.contains(listing.id);
                                return ListingCard(
                                  listing: listing,
                                  isAdded: isAdded,
                                  onAddTap: () => _toggleCart(listing),
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

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),

      // Persistent Blinkit Checkout Floating Bar when services are added!
      bottomSheet: _cartListingIds.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: BlinkitTheme.blinkitGreen,
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_cartListingIds.length} Service(s) Selected',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '📍 $_userLocation • Free Checkout',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BlinkitTheme.blinkitYellow,
                        foregroundColor: const Color(0xFF0C831F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: _openCheckoutModal,
                      icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                      label: const Text(
                        'View Checkout Cart →',
                        style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,

      // Prominent Floating Action Button "+ Post"
      floatingActionButton: _cartListingIds.isEmpty
          ? SizedBox(
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
            )
          : null,
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
