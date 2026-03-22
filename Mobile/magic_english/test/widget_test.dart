import 'package:flutter_test/flutter_test.dart';

import 'package:magic_english/main.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MagicEnglishApp());

    // Verify that app loaded (splash screen should be present)
    await tester.pumpAndSettle();
    
    // Check that the app is running
    expect(find.byType(MagicEnglishApp), findsOneWidget);
  });
}
