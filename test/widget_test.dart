import 'package:flutter_test/flutter_test.dart';
import 'package:schoolapp_web/main.dart';

void main() {
  testWidgets('Home page renders', (tester) async {
    // Build the app
    await tester.pumpWidget(const SchoolApp());

    // Verify something that exists in your UI
    expect(find.text('Savannakhet College — Website'), findsOneWidget);
  });
}
