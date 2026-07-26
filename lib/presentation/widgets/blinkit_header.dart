import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../theme/blinkit_theme.dart';

class BlinkitHeader extends StatelessWidget implements PreferredSizeWidget {
  final String currentNeighborhood;
  final ValueChanged<String> onLocationChanged;

  const BlinkitHeader({
    super.key,
    required this.currentNeighborhood,
    required this.onLocationChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

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
                      Icon(Icons.my_location, color: BlinkitTheme.blinkitGreen, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Select Your Neighborhood',
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
              const SizedBox(height: 12),

              // Custom Neighborhood Input
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'Type custom locality (e.g. Indiranagar, Powai)...',
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check_circle, color: BlinkitTheme.blinkitGreen),
                    onPressed: () {
                      final val = textController.text.trim();
                      if (val.isNotEmpty) {
                        onLocationChanged(val);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    onLocationChanged(val.trim());
                    Navigator.pop(ctx);
                  }
                },
              ),

              const SizedBox(height: 16),
              const Text(
                'Popular Localities',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),

              // Quick Locality Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConfig.popularLocalities.map((loc) {
                  final isSelected = currentNeighborhood == loc;
                  return ChoiceChip(
                    label: Text(loc, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    selected: isSelected,
                    selectedColor: BlinkitTheme.blinkitYellow,
                    onSelected: (selected) {
                      if (selected) {
                        onLocationChanged(loc);
                        Navigator.pop(ctx);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Main header bar showing App LocalHive and current location $currentNeighborhood',
      header: true,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
              // LocalHive Brand Logo (Hexagon Hive Badge, NO blinkit text!)
              Semantics(
                label: 'LocalHive app logo',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [BlinkitTheme.blinkitYellow, Color(0xFFFFB703)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: BlinkitTheme.blinkitYellow.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🐝', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 4),
                      Text(
                        'LocalHive',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Color(0xFF0C831F),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Interactive Delivery & Dynamic Location Selector Pill
              Semantics(
                label: 'Current location $currentNeighborhood. Tap to change location.',
                button: true,
                child: InkWell(
                  onTap: () => _showLocationPicker(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? BlinkitTheme.darkElevated : const Color(0xFFEDF1F7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: BlinkitTheme.blinkitYellow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.bolt, size: 10, color: BlinkitTheme.blinkitGreen),
                              Text(
                                '8 MINS',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: BlinkitTheme.blinkitGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.location_on, size: 12, color: BlinkitTheme.swiggyOrange),
                        const SizedBox(width: 2),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Text(
                            '$currentNeighborhood ▾',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
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
