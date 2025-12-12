// Basic Flutter widget tests for Todo App
// Run tests with: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_flutter/main.dart';

void main() {
  group('Basic App Tests', () {
    testWidgets('App should launch without errors', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Verify the app renders
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Verify app bar exists
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verify title is displayed
      expect(find.text('My Tasks'), findsOneWidget);
    });

    testWidgets('App should have floating action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Should have 2 FABs (Add and AI)
      expect(find.byType(FloatingActionButton), findsNWidgets(2));
    });
  });
}
