import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneysensev2/shared/widgets/ps_action_tile.dart';

void main() {
  testWidgets('PsActionTile displays title and icon', (WidgetTester tester) async {
    const title = 'Test Title';
    const icon = Icons.settings;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PsActionTile(
            title: title,
            icon: icon,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text(title), findsOneWidget);
    expect(find.byIcon(icon), findsOneWidget);
  });

  testWidgets('PsActionTile displays subtitle when provided', (WidgetTester tester) async {
    const title = 'Test Title';
    const subtitle = 'Test Subtitle';
    const icon = Icons.info;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PsActionTile(
            title: title,
            subtitle: subtitle,
            icon: icon,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text(title), findsOneWidget);
    expect(find.text(subtitle), findsOneWidget);
  });

  testWidgets('PsActionTile calls onTap when tapped', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PsActionTile(
            title: 'Tap Me',
            icon: Icons.touch_app,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PsActionTile));
    await tester.pump();

    expect(tapped, true);
  });

  testWidgets('PsActionTile uses correct semantic label', (WidgetTester tester) async {
    const title = 'Test Title';
    const semanticLabel = 'Custom Label';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PsActionTile(
            title: title,
            icon: Icons.settings,
            semanticLabel: semanticLabel,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == semanticLabel,
      ),
      findsOneWidget,
    );
  });
}
