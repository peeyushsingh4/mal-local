import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/seed_data.dart';
import 'domain/services/deterministic_ai_service.dart';
import 'domain/services/local_ai_service.dart';
import 'presentation/screens/feed_screen.dart';
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

  runApp(MalLocalApp(
    repository: repository,
    aiService: aiService,
  ));
}

class MalLocalApp extends StatelessWidget {
  final ListingRepository repository;
  final LocalAiService aiService;

  const MalLocalApp({
    super.key,
    required this.repository,
    required this.aiService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAL Local',
      debugShowCheckedModeBanner: false,
      theme: BlinkitTheme.lightTheme,
      darkTheme: BlinkitTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default Blinkit Dark theme
      showSemanticsDebugger: false,
      home: FeedScreen(
        repository: repository,
        aiService: aiService,
      ),
    );
  }
}
