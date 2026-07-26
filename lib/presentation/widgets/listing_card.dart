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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = ListingCategory.getById(listing.categoryId);
    final statusColor = _getStatusColor(listing.status);
    final isOffer = listing.type == ListingType.offer;

    return Card(
      margin: EdgeInsets.zero,
      elevation: isDark ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Thumbnail Container (Matching Image 3: Padded, centered BoxFit.contain, not stretched!)
              Container(
                height: 110,
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: listing.imageUrl != null && listing.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            listing.imageUrl!,
                            fit: BoxFit.cover,
                            height: 100,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Text(cat.icon, style: const TextStyle(fontSize: 36)),
                          ),
                        )
                      : Text(cat.icon, style: const TextStyle(fontSize: 36)),
                ),
              ),

              const SizedBox(height: 8),

              // Speed Badge (Matching Image 3: "⏱️ 8 MINS")
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 10, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text(
                    '8 MINS',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const Spacer(),
                  // Category Tag
                  Text(
                    '${cat.icon} ${cat.name}',
                    style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Title (Matching Image 3: Bold, 12px)
              Text(
                listing.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 4),

              // Area & Subtext (Matching Image 3: e.g. "32 pcs" / "📍 Pali Hill")
              Text(
                '📍 ${listing.area}',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // Bottom Action Bar (Matching Image 3: Status / Offer tag on left, Green ADD button on right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Tag / Type Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isOffer ? '📤 Offer' : '📥 Request',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ),

                  // Green ADD Button (Matching Image 3: White button with green border and ADD text)
                  Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0C831F).withOpacity(0.15) : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: BlinkitTheme.blinkitGreen, width: 1.2),
                    ),
                    child: const Center(
                      child: Text(
                        'ADD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: BlinkitTheme.blinkitGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
