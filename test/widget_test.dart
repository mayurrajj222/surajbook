// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vypaar/main.dart';

void main() {
  testWidgets('Vyapar 3D App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the business title 'Suraj Book Store' exists in the header
    expect(find.text('Suraj Book Store'), findsOneWidget);

    // Verify that sub-tabs like 'Transaction Details' and 'Party Details' exist
    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text('Party Details'), findsOneWidget);

    // Verify that the pre-seeded member exists in the list
    expect(find.text('Amit Kumar (Member)'), findsOneWidget);

    // Verify that the 'Add New Party' FAB exists
    expect(find.text('Add New Party'), findsOneWidget);
  });
}
