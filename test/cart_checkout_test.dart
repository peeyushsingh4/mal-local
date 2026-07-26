import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mal_local/main.dart';
import 'package:mal_local/data/seed_data.dart';
import 'package:mal_local/domain/models/listing.dart';
import 'package:mal_local/domain/services/deterministic_ai_service.dart';
import 'package:mal_local/repository/local_listing_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Backtest: User can list, add service to cart, and checkout with detailed output receipt', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = LocalListingRepository(prefs);
    await repo.seedIfEmpty(getSeedListings());
    final aiService = DeterministicAiService();

    // 1. Launch App
    await tester.pumpWidget(LocalHiveApp(
      repository: repo,
      aiService: aiService,
    ));

    // Fast forward 1 second for 1-sec pulse logo splash screen to auto-navigate directly to feed!
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // 2. Verify initial seed listings rendered
    expect(find.text('0 Cart'), findsOneWidget);
    expect(find.text('ADD'), findsWidgets);

    // 3. Tap ADD on first listing to add service to cart
    final addButtons = find.text('ADD');
    await tester.tap(addButtons.first);
    await tester.pumpAndSettle();

    // Verify button turned into ADDED ✓ and header cart shows 1 Cart
    expect(find.text('1 Cart'), findsOneWidget);
    expect(find.text('ADDED ✓'), findsOneWidget);

    // 4. Open Checkout Sheet from Top Right Cart Button
    await tester.tap(find.text('1 Cart'));
    await tester.pumpAndSettle();

    // Verify Checkout Sheet title and Contact form present
    expect(find.text('Checkout (1 Service)'), findsOneWidget);
    expect(find.text('Contact & Delivery Information'), findsOneWidget);

    // 5. Submit Checkout
    final confirmButton = find.text('Confirm Service Request · Free Checkout');
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify Output Confirmation Receipt contains Booking Ref ID, Customer Details & Status
    expect(find.text('Service Booking Confirmed!'), findsOneWidget);
    expect(find.text('Booking Ref ID:'), findsOneWidget);
    expect(find.text('Customer Name:'), findsOneWidget);
    expect(find.text('Resident Neighbor'), findsOneWidget);
    expect(find.text('+91 98200 12345'), findsOneWidget);

    // 6. Complete Checkout flow
    await tester.tap(find.text('Done · View My Ordered Services'));
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
      title: 'Emergency Powerbank Share',
      description: 'Fully charged 20000mAh powerbank available for 2 hours',
      type: ListingType.offer,
      categoryId: 'tools',
      area: 'Bandra West',
      status: ListingStatus.active,
      createdAt: DateTime.now(),
    );

    await repo.save(newListing);
    final all = await repo.getAll();

    expect(all.any((l) => l.title == 'Emergency Powerbank Share'), isTrue);
  });
}
