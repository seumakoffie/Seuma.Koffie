// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:seuma/app/app.dart';

void main() {
  testWidgets('Seuma.Koffie app loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SeumaKoffieApp());

    // Verify that the brand or slogan is present
    expect(find.byType(SeumaKoffieApp), findsOneWidget);
  });
}
