import 'package:flutter/foundation.dart';

import '../models/todo.dart';
import '../services/todo_service.dart';

class TodoProvider with ChangeNotifier {
  final TodoService _todoService = TodoService();

  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  // Sort todos: incomplete first, completed last
  List<Todo> get todos {
    final sortedList = List<Todo>.from(_todos);
    sortedList.sort((a, b) {
      if (a.completed == b.completed) return 0;
      return a.completed ? 1 : -1;
    });
    return sortedList;
  }
  
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
      // Toggle = gửi giá trị NGƯỢC LẠI với giá trị hiện tại
      final updatedTodo =
          await _todoService.toggleTodo(todoId, !currentCompleted);
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
    try {
      // Tìm step trong danh sách todos
      TodoStep? targetStep;
      for (final todo in _todos) {
        final step = todo.steps.firstWhere(
          (s) => s.id == stepId,
          orElse: () => TodoStep(title: ''),
        );
        if (step.id == stepId) {
          targetStep = step;
          break;
        }
      }

      if (targetStep == null || targetStep.id == null) return;

      // Toggle step với giá trị NGƯỢC LẠI
      await _todoService.toggleStep(stepId, !targetStep.completed);
      
      // Fetch lại todos để đồng bộ trạng thái todo cha
      // Backend tự động cập nhật completed của todo cha khi toggle step
      await fetchTodos(showLoading: false);
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStepText(int stepId, String newText) async {
    try {
      await _todoService.updateStepTitle(stepId, newText);
      await fetchTodos(showLoading: false);
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addStepToTodo(int todoId, String stepTitle) async {
    try {
      final updatedTodo = await _todoService.addStepToTodo(todoId, stepTitle);
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

