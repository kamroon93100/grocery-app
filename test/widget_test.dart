import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_local/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GroceryApp());

    // Verify that the title or loader is present.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Settle the splash screen delayed future.
    await tester.pump(const Duration(seconds: 4));

    // Force disposal of the widget tree and run pending timers to clean up.
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 1));
  });
}

