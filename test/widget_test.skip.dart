// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Use a RELATIVE import so the analyzer always finds it.
import '../lib/main.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(const SchoolWebApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
