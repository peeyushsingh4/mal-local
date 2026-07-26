import 'package:flutter/material.dart';
import '../../domain/services/local_ai_service.dart';
import '../../domain/services/location_service.dart';
import '../../repository/listing_repository.dart';
import '../theme/blinkit_theme.dart';
import 'feed_screen.dart';

class LandingScreen extends StatefulWidget {
  final ListingRepository repository;
  final LocalAiService aiService;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const LandingScreen({
    super.key,
    required this.repository,
    required this.aiService,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  String _userLocation = 'Detecting location...';

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final loc = await LocationService.getSavedLocation();
    if (loc == 'Detecting location...') {
      final detected = await LocationService.detectCurrentLocation();
      if (mounted) setState(() => _userLocation = detected);
    } else {
      if (mounted) setState(() => _userLocation = loc);
    }
  }

  void _enterMarketplace() {
    context.pushSmooth(FeedScreen(
      repository: widget.repository,
      aiService: widget.aiService,
      onToggleTheme: widget.onToggleTheme,
      isDarkMode: widget.isDarkMode,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark ? BlinkitTheme.darkBg : BlinkitTheme.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? BlinkitTheme.darkBg : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? BlinkitTheme.blinkitYellow : const Color(0xFF0F172A),
            ),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Branded Localhive Graphic Banner (Clean Card Container)
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: BlinkitTheme.blinkitYellow.withOpacity(0.3),
                              blurRadius: 16,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🐝', style: TextStyle(fontSize: 64)),
                          Text('Localhive', style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w900, fontSize: 32, color: BlinkitTheme.blinkitGreen)),
                          Text('hyperlocal app', style: TextStyle(fontSize: 18, color: BlinkitTheme.swiggyOrange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Hero Title
                Text(
                  'Your Neighborhood Marketplace',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w900,
                    fontSize: screenWidth > 600 ? 32 : 24,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle / Tagline
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: Text(
                    'Discover, offer, share, lend, and book local services in $_userLocation — 100% on-device, private, and instant.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth > 600 ? 15 : 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // CTA Button
                SizedBox(
                  height: 52,
                  width: screenWidth > 600 ? 320 : double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BlinkitTheme.blinkitGreen,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _enterMarketplace,
                    icon: const Icon(Icons.storefront, size: 22),
                    label: const Text(
                      'Explore Local Marketplace →',
                      style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Feature Highlights Grid
                Text(
                  'Built for Local Communities',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildFeatureCard(
                      context: context,
                      icon: '📍',
                      title: 'Current Location',
                      desc: 'Auto-detects your current neighborhood or lets you type any custom locality.',
                      isDark: isDark,
                    ),
                    _buildFeatureCard(
                      context: context,
                      icon: '⚡',
                      title: '8-Min Local Board',
                      desc: 'Rapid local listings for food, skills, tool lending, and urgent requests.',
                      isDark: isDark,
                    ),
                    _buildFeatureCard(
                      context: context,
                      icon: '🛒',
                      title: 'Instant Checkout',
                      desc: 'Book local services with free checkout and track active service orders.',
                      isDark: isDark,
                    ),
                    _buildFeatureCard(
                      context: context,
                      icon: '🔒',
                      title: 'Privacy Protected',
                      desc: '100% On-device storage. Coarse areas used — exact home addresses prohibited.',
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? BlinkitTheme.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Sora',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
