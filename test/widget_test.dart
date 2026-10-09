// Test untuk GitFlow App
//
// Smoke test — mastiin app bisa launch tanpa error.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gitflow/main.dart';

void main() {
  testWidgets('GitFlow app renders correctly', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const GitFlowApp());

    // Verify app name muncul
    expect(find.text('GitFlow'), findsOneWidget);
    expect(find.text('Your GitHub, Reimagined'), findsOneWidget);

    // Verify icon code muncul
    expect(find.byIcon(Icons.code), findsOneWidget);
  });
}