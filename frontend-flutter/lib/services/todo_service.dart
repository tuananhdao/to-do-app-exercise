import '../models/todo.dart';
import 'api_service.dart';

class TodoService {
  final ApiService _apiService;

  TodoService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Get all todos
  Future<List<Todo>> getAllTodos() async {
    return await _apiService.getAllTodos();
  }

  // Create a new todo
  Future<Todo> createTodo(String title, List<String> stepTitles) async {
    final steps = stepTitles
        .where((title) => title.trim().isNotEmpty)
        .map((title) => TodoStep(title: title, completed: false))
        .toList();

    return await _apiService.createTodo(
      title: title,
      steps: steps.isNotEmpty ? steps : null,
    );
  }

  // Update todo title
  Future<Todo> updateTodoTitle(int todoId, String newTitle) async {
    return await _apiService.updateTodo(
      id: todoId,
      title: newTitle,
    );
  }

  // Toggle todo completion (toggle all steps)
  Future<Todo> toggleTodo(int todoId, bool completed) async {
    return await _apiService.updateTodo(
      id: todoId,
      completed: completed,
    );
  }

  // Delete todo
  Future<void> deleteTodo(int todoId) async {
    await _apiService.deleteTodo(todoId);
  }

  // Add step to todo
  Future<Todo> addStepToTodo(int todoId, String stepTitle) async {
    return await _apiService.addStepToTodo(
      todoId: todoId,
      stepTitle: stepTitle,
    );
  }

  // Update step
  Future<TodoStep> updateStep({
    required int stepId,
    String? title,
    bool? completed,
  }) async {
    return await _apiService.updateStep(
      stepId: stepId,
      title: title,
      completed: completed,
    );
  }

  // Toggle step completion
  Future<TodoStep> toggleStep(int stepId, bool completed) async {
    return await _apiService.updateStep(
      stepId: stepId,
      completed: completed,
    );
  }

  // Update step title
  Future<TodoStep> updateStepTitle(int stepId, String newTitle) async {
    return await _apiService.updateStep(
      stepId: stepId,
      title: newTitle,
    );
  }

  // Delete step
  Future<void> deleteStep(int stepId) async {
    await _apiService.deleteStep(stepId);
  }

  void dispose() {
    _apiService.dispose();
  }
}
