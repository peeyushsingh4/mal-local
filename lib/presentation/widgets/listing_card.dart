import 'package:flutter/material.dart';
import '../../domain/models/category.dart';
import '../../domain/models/listing.dart';
import '../theme/blinkit_theme.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  Color _getStatusColor(ListingStatus status) {
    switch (status) {
      case ListingStatus.active:
        return BlinkitTheme.blinkitGreen;
      case ListingStatus.saved:
        return const Color(0xFF0284C7);
      case ListingStatus.contacted:
        return const Color(0xFF7C3AED);
      case ListingStatus.closed:
        return const Color(0xFF64748B);
    }
  }

  String _getStatusLabel(ListingStatus status) {
    switch (status) {
      case ListingStatus.active:
        return 'Active';
      case ListingStatus.saved:
        return '★ Saved';
      case ListingStatus.contacted:
        return '✉ Contacted';
      case ListingStatus.closed:
        return '✕ Closed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = ListingCategory.getById(listing.categoryId);
    final statusColor = _getStatusColor(listing.status);
    final isOffer = listing.type == ListingType.offer;

    final composedSemanticLabel =
        'Listing: ${listing.title}. Category: ${cat.name}. Type: ${isOffer ? "Offer" : "Request"}. Area: ${listing.area}. Status: ${_getStatusLabel(listing.status)}.';

    return Semantics(
      label: composedSemanticLabel,
      button: true,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Image / Visual Thumbnail Container for Help Provided
              Stack(
                children: [
                  Container(
                    height: 84,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cat.bgTint,
                    ),
                    child: listing.imageUrl != null && listing.imageUrl!.isNotEmpty
                        ? Image.network(
                            listing.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(cat.icon, style: const TextStyle(fontSize: 32)),
                            ),
                          )
                        : Center(
                            child: Text(cat.icon, style: const TextStyle(fontSize: 32)),
                          ),
                  ),

                  // Overlay Category Pill
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cat.icon} ${cat.name}',
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Overlay 8 MINS Badge
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: BlinkitTheme.blinkitYellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, size: 8, color: BlinkitTheme.blinkitGreen),
                          Text(
                            '8 MINS',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: BlinkitTheme.blinkitGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Card Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        listing.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Description
                      Text(
                        listing.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),

                      // Area & Offer/Request Tag
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '📍 ${listing.area}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: isOffer
                                  ? BlinkitTheme.blinkitGreen.withOpacity(0.12)
                                  : BlinkitTheme.zomatoRed.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isOffer ? 'OFFER' : 'REQ',
                              style: TextStyle(
                                fontSize: 7.5,
                                fontWeight: FontWeight.w900,
                                color: isOffer ? BlinkitTheme.blinkitGreen : BlinkitTheme.zomatoRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Bottom Action Bar (Status Pill + ADD Button)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status Badge Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: statusColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              _getStatusLabel(listing.status),
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: statusColor,
                              ),
                            ),
                          ),

                          // ADD Button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: BlinkitTheme.blinkitGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: BlinkitTheme.blinkitGreen, width: 1.2),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'ADD',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: BlinkitTheme.blinkitGreen,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.add, size: 10, color: BlinkitTheme.blinkitGreen),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
