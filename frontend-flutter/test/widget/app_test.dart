import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_flutter/main.dart';
import 'package:todo_flutter/providers/todo_provider.dart';

void main() {
  group('TodoApp Widget Tests', () {
    testWidgets('App should render with title', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Verify app title is displayed
      expect(find.text('My Tasks'), findsOneWidget);
    });

    testWidgets('App should have FAB buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Verify floating action buttons exist
      expect(find.byType(FloatingActionButton), findsNWidgets(2));
      
      // Verify icons on FABs
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    });

    testWidgets('Refresh button exists in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Verify refresh button (there might be multiple refresh icons)
      expect(find.byIcon(Icons.refresh_rounded), findsAtLeastNWidgets(1));
    });

    testWidgets('Tapping add button should show dialog', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Tap the add button
      final addButton = find.byIcon(Icons.add_rounded);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Should show dialog with title and cancel button
      expect(find.text('Add Todo'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Can close add dialog', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Add Todo'), findsNothing);
    });
  });

  group('TodoProvider Tests', () {
    test('Initial state should be empty', () {
      final provider = TodoProvider();
      
      expect(provider.todos, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });
  });

  group('Theme Tests', () {
    testWidgets('App uses correct primary color', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Verify primary color matches Microsoft blue
      expect(
        materialApp.theme?.colorScheme.primary,
        const Color(0xFF2564CF),
      );
    });

    testWidgets('App has no debug banner', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      expect(materialApp.debugShowCheckedModeBanner, false);
    });
  });
}
