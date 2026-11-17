import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test/main.dart';

void main() {
  testWidgets('Hairstyle Try-On app renders title and API key input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HairstyleTryOnApp());

    expect(find.text('Hairstyle Try-On Demo'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
