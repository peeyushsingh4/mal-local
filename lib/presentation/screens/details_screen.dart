import 'package:flutter/material.dart';
import '../../domain/models/category.dart';
import '../../domain/models/listing.dart';
import '../../domain/services/local_ai_service.dart';
import '../../repository/listing_repository.dart';
import '../theme/blinkit_theme.dart';
import '../widgets/listing_card.dart';

class DetailsScreen extends StatefulWidget {
  final String listingId;
  final ListingRepository repository;
  final LocalAiService aiService;

  const DetailsScreen({
    super.key,
    required this.listingId,
    required this.repository,
    required this.aiService,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Listing? _listing;
  List<Listing> _similarListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadListingDetails();
  }

  Future<void> _loadListingDetails() async {
    setState(() => _isLoading = true);
    final listing = await widget.repository.getById(widget.listingId);
    if (listing != null) {
      final categoryListings = await widget.repository.getByCategory(listing.categoryId);
      final similar = categoryListings.where((l) => l.id != listing.id).take(4).toList();

      setState(() {
        _listing = listing;
        _similarListings = similar;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(ListingStatus newStatus) async {
    if (_listing == null) return;
    try {
      final updated = await widget.repository.updateStatus(_listing!.id, newStatus);
      setState(() => _listing = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked as ${newStatus.name.toUpperCase()}'),
            backgroundColor: BlinkitTheme.blinkitGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    if (_listing == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('Are you sure you want to delete this listing? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: BlinkitTheme.zomatoRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await widget.repository.delete(_listing!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textScaler = MediaQuery.textScalerOf(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator(color: BlinkitTheme.blinkitGreen)),
      );
    }

    if (_listing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Listing Not Found')),
        body: const Center(child: Text('This listing was deleted or does not exist.')),
      );
    }

    final listing = _listing!;
    final cat = ListingCategory.getById(listing.categoryId);
    final isOffer = listing.type == ListingType.offer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Details'),
        actions: [
          Semantics(
            label: 'Delete this listing',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: BlinkitTheme.zomatoRed),
              onPressed: _confirmDelete,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badges Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: BlinkitTheme.blinkitYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '⚡ 8 MINS HYPERLOCAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: BlinkitTheme.blinkitGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cat.bgTint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cat.color),
                  ),
                  child: Text(
                    '${cat.icon} ${cat.name}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: cat.color,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isOffer
                        ? BlinkitTheme.blinkitGreen.withOpacity(0.15)
                        : BlinkitTheme.zomatoRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isOffer ? 'OFFER' : 'REQUEST',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isOffer ? BlinkitTheme.blinkitGreen : BlinkitTheme.zomatoRed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              listing.title,
              style: TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w900,
                fontSize: textScaler.scale(22),
              ),
            ),
            const SizedBox(height: 12),

            // Sub-locality & Preference Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? BlinkitTheme.darkElevated : const Color(0xFFEDF1F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: BlinkitTheme.swiggyOrange, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '📍 ${listing.area}, Bandra West',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  const Icon(Icons.contact_phone, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    listing.contactPreference.name.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description
            const Text(
              'Description',
              style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              listing.description,
              style: TextStyle(
                fontSize: textScaler.scale(15),
                height: 1.5,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 24),

            // Status Actions Buttons Row
            const Text(
              'Update Listing Status',
              style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusButton('★ Save Listing', ListingStatus.saved, const Color(0xFF0284C7)),
                _buildStatusButton('✉ Mark Contacted', ListingStatus.contacted, const Color(0xFF7C3AED)),
                _buildStatusButton('✕ Close Listing', ListingStatus.closed, const Color(0xFF64748B)),
                _buildStatusButton('↩ Reactivate', ListingStatus.active, BlinkitTheme.blinkitGreen),
              ],
            ),

            const SizedBox(height: 32),

            // Original Feature: Nearby Similar Listings Section
            if (_similarListings.isNotEmpty) ...[
              const Text(
                'Nearby Similar Listings in Bandra West',
                style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _similarListings.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, idx) {
                    final item = _similarListings[idx];
                    return SizedBox(
                      width: 170,
                      child: ListingCard(
                        listing: item,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailsScreen(
                                listingId: item.id,
                                repository: widget.repository,
                                aiService: widget.aiService,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, ListingStatus status, Color color) {
    final isCurrent = _listing?.status == status;
    return Semantics(
      label: 'Mark listing status as ${status.name}',
      button: true,
      selected: isCurrent,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isCurrent ? color : Colors.transparent,
          foregroundColor: isCurrent ? Colors.white : color,
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => _updateStatus(status),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            color: isCurrent ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
