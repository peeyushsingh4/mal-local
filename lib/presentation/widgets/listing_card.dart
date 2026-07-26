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

    // Composed semantic label for screen reader accessibility
    final composedSemanticLabel =
        'Listing: ${listing.title}. Category: ${cat.name}. Type: ${isOffer ? "Offer" : "Request"}. Area: ${listing.area}. Status: ${_getStatusLabel(listing.status)}. ${listing.isClosingSoon ? "Closing soon in ${listing.daysRemaining} days" : ""}';

    return Semantics(
      label: composedSemanticLabel,
      button: true,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag Bar: Delivery Speed + Category Pill
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        border: Border.all(color: const Color(0xFFF7C413)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '⚡ 8 MINS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD4A300),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cat.bgTint,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cat.color.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${cat.icon} ${cat.name}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: cat.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  listing.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  listing.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
                const Spacer(),

                // Closing Soon Warning Pill (Original Feature: Self-expiry tracking)
                if (listing.isClosingSoon)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: BlinkitTheme.zomatoRed.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: BlinkitTheme.zomatoRed.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, size: 10, color: BlinkitTheme.zomatoRed),
                        const SizedBox(width: 3),
                        Text(
                          'Closing in ${listing.daysRemaining}d',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: BlinkitTheme.zomatoRed,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Area & Offer/Request Pill
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '📍 ${listing.area}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isOffer
                            ? BlinkitTheme.blinkitGreen.withOpacity(0.12)
                            : BlinkitTheme.zomatoRed.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isOffer ? 'OFFER' : 'REQ',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: isOffer ? BlinkitTheme.blinkitGreen : BlinkitTheme.zomatoRed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Bottom Action Bar (Status Badge + Blinkit ADD button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        _getStatusLabel(listing.status),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                        ),
                      ),
                    ),

                    // Blinkit ADD Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: BlinkitTheme.blinkitGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: BlinkitTheme.blinkitGreen, width: 1.5),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ADD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: BlinkitTheme.blinkitGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.add, size: 12, color: BlinkitTheme.blinkitGreen),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
