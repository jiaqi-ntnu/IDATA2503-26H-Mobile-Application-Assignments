// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_list/main.dart';

void main() {
  /// Defines a widget test that verifies UI rendering and behavior.
  /// [WidgetTester] allows programmatic building and interacting with widgets in an isolated test environment.
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build the widget tree and trigger a frame to render the root application widget.
    await tester.pumpWidget(const MyApp());

    // Verify that our initial state is rendered as expected.
    // Finds widgets displaying specific text and asserts the count of occurrences.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Simulate a user tap gesture on a widget found by its icon.
    await tester.tap(find.byIcon(Icons.add));
    // Trigger a frame rebuild after the interaction to reflect any state changes.
    await tester.pump();

    // Verify that the UI updated following the interaction.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
