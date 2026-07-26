import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mal_local/main.dart';
import 'package:mal_local/repository/local_listing_repository.dart';
import 'package:mal_local/domain/services/deterministic_ai_service.dart';

void main() {
  testWidgets('LocalHive App loads splash screen and transitions to feed', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = LocalListingRepository(prefs);
    final aiService = DeterministicAiService();

    await tester.pumpWidget(LocalHiveApp(
      repository: repo,
      aiService: aiService,
    ));

    // Fast-forward 1 second for splash animation auto-navigation
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('0 Cart'), findsOneWidget);
  });
}
