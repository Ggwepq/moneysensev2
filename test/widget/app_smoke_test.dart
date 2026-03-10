import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneysensev2/app/app.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MoneySenseApp()));

    // Just verify it builds and shows something
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
