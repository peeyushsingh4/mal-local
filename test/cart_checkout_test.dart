import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mal_local/main.dart';
import 'package:mal_local/repository/local_listing_repository.dart';
import 'package:mal_local/domain/services/deterministic_ai_service.dart';
import 'package:mal_local/data/seed_data.dart';
import 'package:mal_local/domain/models/listing.dart';

void main() {
  testWidgets('Backtest: User can list, add service to cart, and checkout with detailed output receipt', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = LocalListingRepository(prefs);
    final aiService = DeterministicAiService();

    // 1. Seed initial listings
    await repo.seedIfEmpty(getSeedListings());

    // 2. Pump App
    await tester.pumpWidget(LocalHiveApp(
      repository: repo,
      aiService: aiService,
    ));
    await tester.pumpAndSettle();

    // Verify App header and initial seed listings exist
    expect(find.text('LocalHive'), findsOneWidget);
    expect(find.text('0 Cart'), findsOneWidget);

    // 3. Backtest Cart Addition: Tap 'ADD' on first service card
    final addButtons = find.text('ADD');
    expect(addButtons, findsWidgets);

    await tester.tap(addButtons.first);
    await tester.pumpAndSettle();

    // Verify Cart Counter updated to '1 Cart' and button shows 'ADDED ✓'
    expect(find.text('1 Cart'), findsOneWidget);
    expect(find.text('ADDED ✓'), findsOneWidget);

    // 4. Backtest Checkout Modal: Tap top right Cart button
    await tester.tap(find.text('1 Cart'));
    await tester.pumpAndSettle();

    // Verify Checkout Sheet opened with Contact & Delivery fields
    expect(find.textContaining('Checkout'), findsWidgets);
    expect(find.text('Contact & Delivery Information'), findsOneWidget);

    // 5. Backtest Confirm Order
    final confirmButton = find.text('Confirm Service Request · Free Checkout');
    expect(confirmButton, findsOneWidget);

    await tester.tap(confirmButton);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Verify Output Confirmation Receipt contains Booking ID, Customer Details & Status
    expect(find.text('Service Booking Confirmed!'), findsOneWidget);
    expect(find.text('Booking ID:'), findsOneWidget);
    expect(find.text('Customer Name:'), findsOneWidget);
    expect(find.text('Resident Neighbor'), findsOneWidget);
    expect(find.text('+91 98200 12345'), findsOneWidget);

    // 6. Complete Checkout flow
    await tester.tap(find.text('Done · Return to Local Board'));
    await tester.pumpAndSettle();

    // Cart should be reset to 0
    expect(find.text('0 Cart'), findsOneWidget);
  });

  testWidgets('Backtest: User can create a new listing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = LocalListingRepository(prefs);

    final newListing = Listing(
      id: 'test-custom-1',
      title: 'Custom AC Repair Service',
      categoryId: 'services',
      description: 'Quick home AC service and gas refilling in Pali Hill.',
      area: 'Pali Hill',
    );

    await repo.save(newListing);

    final all = await repo.getAll();
    expect(all.any((l) => l.title == 'Custom AC Repair Service'), isTrue);
  });
}
