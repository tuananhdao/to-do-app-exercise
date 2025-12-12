import 'package:flutter_test/flutter_test.dart';
import 'package:todo_flutter/models/todo.dart';

void main() {
  group('Todo Model Tests', () {
    test('Create Todo with required fields', () {
      final todo = Todo(
        id: 1,
        title: 'Test Todo',
        steps: [],
      );

      expect(todo.id, 1);
      expect(todo.title, 'Test Todo');
      expect(todo.completed, false);
      expect(todo.steps, isEmpty);
    });

    test('Create Todo with steps', () {
      final steps = [
        TodoStep(id: 1, title: 'Step 1', completed: false),
        TodoStep(id: 2, title: 'Step 2', completed: false),
      ];

      final todo = Todo(
        id: 1,
        title: 'Todo with steps',
        steps: steps,
      );

      expect(todo.steps.length, 2);
      expect(todo.steps[0].title, 'Step 1');
      expect(todo.steps[1].title, 'Step 2');
    });

    test('Todo fromJson should parse correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Todo',
        'completed': false,
        'steps': [
          {'id': 1, 'items': 'Step 1', 'completed': false},
          {'id': 2, 'items': 'Step 2', 'completed': true},
        ],
      };

      final todo = Todo.fromJson(json);

      expect(todo.id, 1);
      expect(todo.title, 'Test Todo');
      expect(todo.steps.length, 2);
      expect(todo.steps[0].completed, false);
      expect(todo.steps[1].completed, true);
    });

    test('Todo toJson should serialize correctly', () {
      final todo = Todo(
        id: 1,
        title: 'Test Todo',
        steps: [
          TodoStep(id: 1, title: 'Step 1', completed: false),
        ],
      );

      final json = todo.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Test Todo');
      expect(json['completed'], false);
      expect(json['steps'], isA<List>());
      expect((json['steps'] as List).length, 1);
    });

    test('Todo isCompleted when all steps are done', () {
      final todo = Todo(
        id: 1,
        title: 'Test Todo',
        steps: [
          TodoStep(id: 1, title: 'Step 1', completed: true),
          TodoStep(id: 2, title: 'Step 2', completed: true),
        ],
      );

      expect(todo.isCompleted, true);
      expect(todo.completed, true);
    });

    test('Todo not completed when some steps incomplete', () {
      final todo = Todo(
        id: 1,
        title: 'Test Todo',
        steps: [
          TodoStep(id: 1, title: 'Step 1', completed: true),
          TodoStep(id: 2, title: 'Step 2', completed: false),
        ],
      );

      expect(todo.isCompleted, false);
      expect(todo.completed, false);
    });

    test('Count completed steps', () {
      final steps = [
        TodoStep(id: 1, title: 'Step 1', completed: true),
        TodoStep(id: 2, title: 'Step 2', completed: false),
        TodoStep(id: 3, title: 'Step 3', completed: true),
      ];

      final todo = Todo(
        id: 1,
        title: 'Test Todo',
        steps: steps,
      );

      final completedCount = todo.steps.where((s) => s.completed).length;
      expect(completedCount, 2);
      expect(todo.steps.length, 3);
    });

    test('copyWith should create new instance with updated values', () {
      final todo = Todo(
        id: 1,
        title: 'Original Title',
        steps: [],
      );

      final updated = todo.copyWith(title: 'Updated Title');

      expect(updated.id, 1);
      expect(updated.title, 'Updated Title');
      expect(todo.title, 'Original Title'); // Original unchanged
    });
  });

  group('TodoStep Model Tests', () {
    test('Create TodoStep with required fields', () {
      final step = TodoStep(
        id: 1,
        title: 'Test Step',
        completed: false,
      );

      expect(step.id, 1);
      expect(step.title, 'Test Step');
      expect(step.items, 'Test Step'); // items is alias for title
      expect(step.completed, false);
    });

    test('TodoStep fromJson should parse correctly', () {
      final json = {
        'id': 1,
        'items': 'Test Step',
        'completed': true,
      };

      final step = TodoStep.fromJson(json);

      expect(step.id, 1);
      expect(step.title, 'Test Step');
      expect(step.items, 'Test Step');
      expect(step.completed, true);
    });

    test('TodoStep toJson should serialize correctly', () {
      final step = TodoStep(
        id: 1,
        title: 'Test Step',
        completed: false,
      );

      final json = step.toJson();

      expect(json['id'], 1);
      expect(json['items'], 'Test Step');
      expect(json['completed'], false);
    });

    test('Toggle step completion status', () {
      final step = TodoStep(
        id: 1,
        title: 'Test Step',
        completed: false,
      );

      final updatedStep = step.copyWith(completed: !step.completed);

      expect(step.completed, false); // Original unchanged
      expect(updatedStep.completed, true);
    });

    test('copyWith should create new instance', () {
      final step = TodoStep(
        id: 1,
        title: 'Original',
        completed: false,
      );

      final updated = step.copyWith(title: 'Updated', completed: true);

      expect(updated.title, 'Updated');
      expect(updated.completed, true);
      expect(step.title, 'Original'); // Original unchanged
    });
  });
}
