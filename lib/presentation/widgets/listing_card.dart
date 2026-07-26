import 'package:flutter/material.dart';
import '../../domain/models/category.dart';
import '../../domain/models/listing.dart';
import '../theme/blinkit_theme.dart';

class ListingCard extends StatefulWidget {
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

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  bool _isHovered = false;

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
    final cat = ListingCategory.getById(widget.listing.categoryId);
    final statusColor = _getStatusColor(widget.listing.status);
    final isOffer = widget.listing.type == ListingType.offer;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered ? (Matrix4.identity()..translate(0, -3, 0)) : Matrix4.identity(),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: _isHovered ? 6 : (isDark ? 1 : 2),
          shadowColor: BlinkitTheme.blinkitGreen.withOpacity(_isHovered ? 0.25 : 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: _isHovered
                  ? BlinkitTheme.blinkitGreen
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: _isHovered ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Thumbnail Container (Centered BoxFit.contain)
                  Container(
                    height: 102,
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: widget.listing.imageUrl != null && widget.listing.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.listing.imageUrl!,
                                fit: BoxFit.cover,
                                height: 94,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => Text(cat.icon, style: const TextStyle(fontSize: 34)),
                              ),
                            )
                          : Text(cat.icon, style: const TextStyle(fontSize: 34)),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Speed & Category Tags
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 11, color: BlinkitTheme.swiggyOrange),
                      const SizedBox(width: 3),
                      Text(
                        '8 MINS',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${cat.icon} ${cat.name}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Enhanced Title Text (Max 2 lines)
                  Text(
                    widget.listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Area Text
                  Text(
                    '📍 ${widget.listing.area}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.5,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  // Bottom Action Bar (Status Pill on left, Green ADD / ADDED button on right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Type Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOffer ? '📤 Offer' : '📥 Request',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                          ),
                        ),
                      ),

                      // Green ADD / ADDED Checkout Toggle Button
                      InkWell(
                        onTap: widget.onAddTap,
                        borderRadius: BorderRadius.circular(7),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: widget.isAdded
                                ? BlinkitTheme.blinkitGreen
                                : (isDark ? const Color(0xFF0C831F).withOpacity(0.18) : Colors.white),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: BlinkitTheme.blinkitGreen, width: 1.3),
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                              child: Text(
                                widget.isAdded ? 'ADDED ✓' : 'ADD',
                                key: ValueKey(widget.isAdded),
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                  color: widget.isAdded ? Colors.white : BlinkitTheme.blinkitGreen,
                                ),
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
        ),
      ),
    );
  }
}
