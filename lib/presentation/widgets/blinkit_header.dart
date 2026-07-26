import 'package:flutter/material.dart';
import '../../domain/services/location_service.dart';
import '../theme/blinkit_theme.dart';

class BlinkitHeader extends StatefulWidget implements PreferredSizeWidget {
  final String currentNeighborhood;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String>? onSearchChanged;
  final int cartCount;
  final VoidCallback onCartTap;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const BlinkitHeader({
    super.key,
    required this.currentNeighborhood,
    required this.onLocationChanged,
    this.onSearchChanged,
    required this.cartCount,
    required this.onCartTap,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  State<BlinkitHeader> createState() => _BlinkitHeaderState();
}

class _BlinkitHeaderState extends State<BlinkitHeader> {
  bool _isDetecting = false;
  final TextEditingController _searchController = TextEditingController();

  void _showLocationPicker(BuildContext context) {
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: BlinkitTheme.blinkitGreen, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Select Your Location',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Button 1: Detect Current Location via Geolocation API
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BlinkitTheme.blinkitGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isDetecting
                          ? null
                          : () async {
                              setModalState(() => _isDetecting = true);
                              final detected = await LocationService.detectCurrentLocation();
                              if (context.mounted) {
                                setModalState(() => _isDetecting = false);
                                widget.onLocationChanged(detected);
                                Navigator.pop(ctx);
                              }
                            },
                      icon: _isDetecting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.my_location, size: 20),
                      label: Text(
                        _isDetecting ? 'Detecting your location...' : '📍 Use My Current Location',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('OR TYPE LOCALITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Custom Locality Text Input
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Kachore Gaon, Dombivli, Maharashtra',
                      isDense: true,
                      prefixIcon: const Icon(Icons.edit_location_alt, size: 20),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check_circle, color: BlinkitTheme.blinkitGreen),
                        onPressed: () {
                          final val = textController.text.trim();
                          if (val.isNotEmpty) {
                            LocationService.saveLocation(val);
                            widget.onLocationChanged(val);
                            Navigator.pop(ctx);
                          }
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        LocationService.saveLocation(val.trim());
                        widget.onLocationChanged(val.trim());
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? BlinkitTheme.darkBg : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: Row(
          children: [
            // LocalHive Brand Logo (Left)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: BlinkitTheme.blinkitYellow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'LocalHive',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Color(0xFF0C831F),
                  letterSpacing: -0.4,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Location Header Block ("Delivery in 8 minutes \n Location ▾")
            InkWell(
              onTap: () => _showLocationPicker(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery in 8 minutes',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 130),
                          child: Text(
                            widget.currentNeighborhood,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 16, color: BlinkitTheme.swiggyOrange),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Search Bar Input (Center)
            if (widget.onSearchChanged != null)
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? BlinkitTheme.darkElevated : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search "tiffin", "tutor", "books"...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),

            const SizedBox(width: 8),

            // Theme Mode Toggle Button (☀️ / 🌙)
            if (widget.onToggleTheme != null)
              IconButton(
                tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  size: 20,
                  color: isDark ? BlinkitTheme.blinkitYellow : const Color(0xFF0F172A),
                ),
                onPressed: widget.onToggleTheme,
              ),

            // Top Right Interactive Cart / Checkout Button (Green Blinkit Badge)
            InkWell(
              onTap: widget.onCartTap,
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.cartCount > 0
                      ? BlinkitTheme.blinkitGreen
                      : (isDark ? BlinkitTheme.darkElevated : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                  border: isDark && widget.cartCount == 0
                      ? Border.all(color: const Color(0xFF334155))
                      : null,
                  boxShadow: widget.cartCount > 0
                      ? [BoxShadow(color: BlinkitTheme.blinkitGreen.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      size: 15,
                      color: widget.cartCount > 0 ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.cartCount > 0 ? '${widget.cartCount} Cart' : '0 Cart',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.w900,
                        fontSize: 11.5,
                        color: widget.cartCount > 0 ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
