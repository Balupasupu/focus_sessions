import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:focus_sessions/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen displays the Focus Sessions title',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('Focus Sessions'), findsOneWidget);
  });
}