import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_alpaca/main.dart';

void main() {
  testWidgets('renders app bar title', (WidgetTester tester) async {
    // Pump the app with required constructor args
    await tester.pumpWidget(
      const MyApp(
        keyId: 'TEST_KEY',
        secret: 'TEST_SECRET',
        baseUrl: 'https://paper-api.alpaca.markets/v2',
      ),
    );

    // Verify the app title is visible
    expect(find.text('Alpaca Account'), findsOneWidget);

    // Let any async frames settle (FutureBuilder may resolve to error in tests — that's fine)
    await tester.pumpAndSettle();

    // Still should have the title
    expect(find.text('Alpaca Account'), findsOneWidget);
  });
}
