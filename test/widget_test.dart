import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mal_local/main.dart';
import 'package:mal_local/repository/local_listing_repository.dart';
import 'package:mal_local/domain/services/deterministic_ai_service.dart';

void main() {
  testWidgets('App loads cleanly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = LocalListingRepository(prefs);
    final aiService = DeterministicAiService();

    await tester.pumpWidget(MalLocalApp(
      repository: repo,
      aiService: aiService,
    ));

    expect(find.text('MAL LOCAL'), findsOneWidget);
  });
}
