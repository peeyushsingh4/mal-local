import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/seed_data.dart';
import 'domain/services/deterministic_ai_service.dart';
import 'domain/services/local_ai_service.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/theme/blinkit_theme.dart';
import 'repository/listing_repository.dart';
import 'repository/local_listing_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences & Local Repository
  final prefs = await SharedPreferences.getInstance();
  final repository = LocalListingRepository(prefs);

  // Seed initial listings if empty
  await repository.seedIfEmpty(getSeedListings());

  // Instantiate AI Service boundary
  final LocalAiService aiService = DeterministicAiService();

  runApp(LocalHiveApp(
    repository: repository,
    aiService: aiService,
  ));
}

class LocalHiveApp extends StatefulWidget {
  final ListingRepository repository;
  final LocalAiService aiService;

  const LocalHiveApp({
    super.key,
    required this.repository,
    required this.aiService,
  });

  @override
  State<LocalHiveApp> createState() => _LocalHiveAppState();
}

class _LocalHiveAppState extends State<LocalHiveApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeMode == ThemeMode.dark;

    return MaterialApp(
      title: 'LocalHive',
      debugShowCheckedModeBanner: false,
      theme: BlinkitTheme.lightTheme,
      darkTheme: BlinkitTheme.darkTheme,
      themeMode: _themeMode,
      showSemanticsDebugger: false,
      builder: (context, child) {
        return AnimatedTheme(
          data: isDark ? BlinkitTheme.darkTheme : BlinkitTheme.lightTheme,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: SplashScreen(
        repository: widget.repository,
        aiService: widget.aiService,
        onToggleTheme: _toggleTheme,
        isDarkMode: isDark,
      ),
    );
  }
}
