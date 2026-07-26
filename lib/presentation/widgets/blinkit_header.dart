import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../theme/blinkit_theme.dart';

class BlinkitHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onLocationTap;

  const BlinkitHeader({super.key, this.onLocationTap});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Main header bar showing delivery time 8 minutes and current neighborhood ${AppConfig.defaultNeighborhoodName}, Mumbai',
      header: true,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              // Logo Badge
              Semantics(
                label: 'Blinkit MAL Local app logo',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: BlinkitTheme.blinkitYellow,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: BlinkitTheme.blinkitYellow.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'blinkit',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: BlinkitTheme.blinkitGreen,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'MAL LOCAL',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),

              // Delivery Time & Location Pill
              Semantics(
                label: 'Delivery location ${AppConfig.defaultNeighborhoodName}, Mumbai. Delivery in 8 minutes',
                button: true,
                child: InkWell(
                  onTap: onLocationTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: BlinkitTheme.blinkitYellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.bolt, size: 12, color: BlinkitTheme.blinkitGreen),
                              Text(
                                '8 MINS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: BlinkitTheme.blinkitGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.location_on, size: 14, color: BlinkitTheme.swiggyOrange),
                        const SizedBox(width: 2),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 110),
                          child: Text(
                            '${AppConfig.defaultNeighborhoodName} ▾',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
