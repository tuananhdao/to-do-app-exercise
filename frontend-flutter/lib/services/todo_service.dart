import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/api_response.dart';
import '../models/todo.dart';
import '../models/todo_step.dart';

/// Encapsulates all Todo-related API calls.
class TodoService {
  TodoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> get _jsonHeaders => const {
        'Content-Type': 'application/json',
      };

  ApiResponse<T> _parseResponse<T>(
    http.Response response,
    T Function(Object? json) fromJsonT,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Request failed (${response.statusCode}): ${response.reasonPhrase}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ApiResponse<T>.fromJson(decoded, fromJsonT);
  }

  Future<List<Todo>> getAllTodos() async {
    final res = await _client.get(Uri.parse(TODOS_BASE_URL));
    final apiRes = _parseResponse<List<Todo>>(res, (json) {
      final list = (json as List<dynamic>? ?? []);
      return list
          .map((item) => Todo.fromJson(item as Map<String, dynamic>))
          .toList();
    });

    return apiRes.data ?? [];
  }

  Future<Todo> createTodo(String title, List<String> steps) async {
    final body = {
      'title': title,
      'completed': false,
      'steps': steps
          .map((s) => {
                'items': s,
                'completed': false,
              })
          .toList(),
    };

    final res = await _client.post(
      Uri.parse(TODOS_BASE_URL),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    final apiRes = _parseResponse<Todo>(
      res,
      (json) => Todo.fromJson(json as Map<String, dynamic>),
    );

    if (apiRes.data == null) {
      throw Exception(apiRes.message ?? 'Unknown error when creating todo');
    }
    return apiRes.data!;
  }

  Future<Todo> toggleTodo(int todoId, bool currentCompleted) async {
    final res = await _client.patch(
      Uri.parse('$TODOS_BASE_URL/$todoId'),
      headers: _jsonHeaders,
      body: jsonEncode({'completed': !currentCompleted}),
    );

    final apiRes = _parseResponse<Todo>(
      res,
      (json) => Todo.fromJson(json as Map<String, dynamic>),
    );

    if (apiRes.data == null) {
      throw Exception(apiRes.message ?? 'Failed to toggle todo');
    }
    return apiRes.data!;
  }

  Future<Todo> updateTodoTitle(int todoId, String newTitle) async {
    final res = await _client.patch(
      Uri.parse('$TODOS_BASE_URL/$todoId'),
      headers: _jsonHeaders,
      body: jsonEncode({'title': newTitle}),
    );

    final apiRes = _parseResponse<Todo>(
      res,
      (json) => Todo.fromJson(json as Map<String, dynamic>),
    );

    if (apiRes.data == null) {
      throw Exception(apiRes.message ?? 'Failed to update title');
    }
    return apiRes.data!;
  }

  Future<void> deleteTodo(int todoId) async {
    final res = await _client.delete(
      Uri.parse('$TODOS_BASE_URL/$todoId'),
      headers: _jsonHeaders,
    );

    _parseResponse<String?>(res, (json) => json?.toString());
  }

  Future<TodoStep> toggleStep(int stepId, bool currentCompleted) async {
    final res = await _client.patch(
      Uri.parse('$TODOS_BASE_URL/items/$stepId'),
      headers: _jsonHeaders,
      body: jsonEncode({'completed': !currentCompleted}),
    );

    final apiRes = _parseResponse<TodoStep>(
      res,
      (json) => TodoStep.fromJson(json as Map<String, dynamic>),
    );

    if (apiRes.data == null) {
      throw Exception(apiRes.message ?? 'Failed to toggle step');
    }
    return apiRes.data!;
  }

  Future<void> updateStepText(int stepId, String newText) async {
    final res = await _client.patch(
      Uri.parse('$TODOS_BASE_URL/items/$stepId'),
      headers: _jsonHeaders,
      body: jsonEncode({'text': newText}),
    );

    _parseResponse<TodoStep>(
      res,
      (json) => TodoStep.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> deleteStep(int stepId) async {
    final res = await _client.delete(
      Uri.parse('$TODOS_BASE_URL/items/$stepId'),
      headers: _jsonHeaders,
    );

    _parseResponse<String?>(res, (json) => json?.toString());
  }
}
