import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_event_explorer/main.dart';

Future<void> pumpApp(WidgetTester tester) async {
  // Phone-sized screen so layout overflows would fail the test.
  tester.view.physicalSize = const Size(400, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const CampusEventExplorerApp());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Explore shows 6 events and marks the initially full one as Full',
      (tester) async {
    await pumpApp(tester);
    expect(find.text('Explore Campus Events'), findsOneWidget);
    expect(find.text('Matching events: 6'), findsOneWidget);
    expect(find.text('Full (0 / 50 places)'), findsOneWidget);
  });

  testWidgets('Search ignores case and spaces, works with category, empty state and clear',
      (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), '  SPORTS  ');
    await tester.pumpAndSettle();
    expect(find.text('Matching events: 1'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Technology'));
    await tester.pumpAndSettle();
    expect(find.text('Matching events: 0'), findsOneWidget);
    expect(find.text('No events match your current search or category filter.'),
        findsOneWidget);

    await tester.tap(find.text('Clear Search & Filters'));
    await tester.pumpAndSettle();
    expect(find.text('Matching events: 6'), findsOneWidget);
  });

  testWidgets('Join: No leaves data unchanged, Yes joins once; last place can be cancelled',
      (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.byType(TextField), 'sports day');
    await tester.pumpAndSettle();
    expect(find.text('1 / 30 places available'), findsOneWidget);

    // No -> nothing changes
    await tester.tap(find.widgetWithText(TextButton, 'Join'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm Participation'), findsOneWidget);
    expect(find.text('Sports Day 2026'), findsWidgets);
    expect(find.textContaining('Venue: Conference Hall A'), findsOneWidget);
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 30 places available'), findsOneWidget);
    expect(find.text('Joined: 0'), findsOneWidget);

    // Yes -> joined once, last place taken
    await tester.tap(find.widgetWithText(TextButton, 'Join'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.text('Full (0 / 30 places)'), findsOneWidget);
    expect(find.text('Joined: 1'), findsOneWidget);
    expect(find.text('My Events (1)'), findsOneWidget);

    // Student who took the last place can still cancel (with confirmation)
    final cancelButton = find.widgetWithText(TextButton, 'Cancel participation');
    expect(cancelButton, findsOneWidget);
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
    expect(find.text('Cancel Participation'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 30 places available'), findsOneWidget);
    expect(find.text('Joined: 0'), findsOneWidget);
  });

  testWidgets('Favorites and My Events show empty states; favorite updates Favorites view',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('My Events (0)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('not joined any events'), findsOneWidget);

    await tester.tap(find.text('Favorites (0)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('no favorite events yet'), findsOneWidget);

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favorites (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Matching events: 1'), findsOneWidget);
    expect(find.text('Campus Art Festival'), findsOneWidget);

    // un-favorite again so state is clean
    await tester.tap(find.byIcon(Icons.favorite).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('no favorite events yet'), findsOneWidget);
  });

  testWidgets('Details opens, double-tap on image opens enlarged viewer, Back works',
      (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'tech conference');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tech Conference 26'));
    await tester.pumpAndSettle();
    expect(find.text('Event Details'), findsOneWidget);

    final image = find.byType(Image).first;
    await tester.tap(image);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(image);
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Event Details'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Explore Campus Events'), findsOneWidget);
  });
}
