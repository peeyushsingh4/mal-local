import 'package:flutter/material.dart';
import '../../domain/services/local_ai_service.dart';
import '../../repository/listing_repository.dart';
import '../theme/blinkit_theme.dart';
import 'feed_screen.dart';

class SplashScreen extends StatefulWidget {
  final ListingRepository repository;
  final LocalAiService aiService;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const SplashScreen({
    super.key,
    required this.repository,
    required this.aiService,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // 1-second pulse animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Auto navigate after 1 second directly to FeedScreen!
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => FeedScreen(
              repository: widget.repository,
              aiService: widget.aiService,
              onToggleTheme: widget.onToggleTheme,
              isDarkMode: widget.isDarkMode,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BlinkitTheme.darkBg : BlinkitTheme.lightBg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: BlinkitTheme.blinkitYellow.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180, maxWidth: 360),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🐝', style: TextStyle(fontSize: 54)),
                      SizedBox(height: 8),
                      Text('Localhive', style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w900, fontSize: 28, color: BlinkitTheme.blinkitGreen)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
