import 'package:flutter/foundation.dart';

import '../models/todo.dart';
import '../services/todo_service.dart';

class TodoProvider with ChangeNotifier {
  final TodoService _todoService = TodoService();

  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTodos({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    _error = null;
    try {
      _todos = await _todoService.getAllTodos();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> addTodo(String title, List<String> steps) async {
    try {
      final newTodo = await _todoService.createTodo(title, steps);
      _todos = [..._todos, newTodo];
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleTodo(int todoId) async {
    final todoIndex = _todos.indexWhere((t) => t.id == todoId);
    if (todoIndex == -1) return;

    final currentCompleted = _todos[todoIndex].completed;
    try {
      final updatedTodo =
          await _todoService.toggleTodo(todoId, currentCompleted);
      _todos = [
        for (final todo in _todos)
          if (todo.id == todoId) updatedTodo else todo,
      ];
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTodoTitle(int todoId, String newTitle) async {
    final todoIndex = _todos.indexWhere((t) => t.id == todoId);
    if (todoIndex == -1) return;

    try {
      final updatedTodo = await _todoService.updateTodoTitle(
        todoId,
        newTitle,
      );
      _todos = [
        for (final todo in _todos)
          if (todo.id == todoId) updatedTodo else todo,
      ];
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTodo(int todoId) async {
    try {
      await _todoService.deleteTodo(todoId);
      _todos = _todos.where((t) => t.id != todoId).toList();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleStep(int stepId) async {
    for (var i = 0; i < _todos.length; i++) {
      final todo = _todos[i];
      final stepIndex = todo.steps.indexWhere((s) => s.id == stepId);
      if (stepIndex == -1) continue;

      final currentStep = todo.steps[stepIndex];

      try {
        final updatedStep =
            await _todoService.toggleStep(stepId, currentStep.completed);

        final updatedSteps = [...todo.steps];
        updatedSteps[stepIndex] = updatedStep;

        final allStepsCompleted =
            updatedSteps.isNotEmpty && updatedSteps.every((s) => s.completed);

        final updatedTodo = Todo(
          id: todo.id,
          title: todo.title,
          completed: allStepsCompleted,
          createdAt: todo.createdAt,
          steps: updatedSteps,
        );

        _todos = [
          for (final t in _todos) if (t.id == todo.id) updatedTodo else t,
        ];
        _error = null;
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
        rethrow;
      }
      return;
    }
  }

  Future<void> updateStepText(int stepId, String newText) async {
    try {
      await _todoService.updateStepText(stepId, newText);
      await fetchTodos(showLoading: false);
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteStep(int stepId) async {
    try {
      await _todoService.deleteStep(stepId);
      await fetchTodos(showLoading: false); // refresh to sync parent todo status
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

}

