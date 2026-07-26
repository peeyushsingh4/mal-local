import 'package:flutter/material.dart';
import '../../domain/models/category.dart';
import '../../domain/models/listing.dart';
import '../theme/blinkit_theme.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final bool isAdded;
  final VoidCallback onAddTap;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.isAdded = false,
    required this.onAddTap,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Thumbnail Container (Matching Image 3: Padded, centered BoxFit.contain, not stretched!)
              Container(
                height: 100,
                width: double.infinity,
                padding: const EdgeInsets.all(4),
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
                            height: 92,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Text(cat.icon, style: const TextStyle(fontSize: 32)),
                          ),
                        )
                      : Text(cat.icon, style: const TextStyle(fontSize: 32)),
                ),
              ),

              const SizedBox(height: 6),

              // Speed & Category Tags
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
                  Text(
                    '${cat.icon} ${cat.name}',
                    style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Title (Max 2 lines)
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

              // Area & Subtext
              Text(
                '📍 ${listing.area}',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              // Bottom Action Bar (Status Pill on left, Green ADD / ADDED button on right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Type Pill
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

                  // Green ADD / ADDED Checkout Toggle Button
                  InkWell(
                    onTap: onAddTap,
                    borderRadius: BorderRadius.circular(6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isAdded
                            ? BlinkitTheme.blinkitGreen
                            : (isDark ? const Color(0xFF0C831F).withOpacity(0.15) : Colors.white),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: BlinkitTheme.blinkitGreen, width: 1.2),
                      ),
                      child: Center(
                        child: Text(
                          isAdded ? 'ADDED ✓' : 'ADD',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: isAdded ? Colors.white : BlinkitTheme.blinkitGreen,
                          ),
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
