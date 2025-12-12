import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/todo.dart';

class ApiResponse<T> {
  final int code;
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  ApiResponse({
    required this.code,
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    // Backend uses 'result' instead of 'data'
    final resultData = json['result'] ?? json['data'];
    final code = json['code'] as int? ?? 0;
    
    return ApiResponse<T>(
      code: code,
      success: code == 1000, // 1000 means success in backend
      data: resultData != null && fromJsonT != null
          ? fromJsonT(resultData)
          : resultData as T?,
      error: json['error'] as String?,
      message: json['message'] as String?,
    );
  }
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // GET all todos
  Future<List<Todo>> getAllTodos() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.getTodosUrl()),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
          null,
        );

        if (apiResponse.success && apiResponse.data != null) {
          final List<dynamic> todosJson = apiResponse.data as List<dynamic>;
          return todosJson
              .map((json) => Todo.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        throw Exception(apiResponse.error ?? 'Failed to load todos');
      } else {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching todos: $e');
    }
  }

  // POST create todo
  Future<Todo> createTodo({
    required String title,
    List<TodoStep>? steps,
  }) async {
    try {
      final body = json.encode({
        'title': title,
        'completed': false,
        if (steps != null && steps.isNotEmpty)
          'steps': steps.map((s) => s.toJson()).toList(),
      });

      final response = await _client.post(
        Uri.parse(ApiConfig.getTodosUrl()),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
          (data) => Todo.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        }
        throw Exception(apiResponse.error ?? 'Failed to create todo');
      } else {
        final errorBody = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(errorBody['error'] ?? 'Failed to create todo');
      }
    } catch (e) {
      throw Exception('Error creating todo: $e');
    }
  }

  // PATCH update todo
  Future<Todo> updateTodo({
    required int id,
    String? title,
    bool? completed,
  }) async {
    try {
      final body = json.encode({
        if (title != null) 'title': title,
        if (completed != null) 'completed': completed,
      });

      final response = await _client.patch(
        Uri.parse(ApiConfig.getTodoUrl(id)),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
          (data) => Todo.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        }
        throw Exception(apiResponse.error ?? 'Failed to update todo');
      } else if (response.statusCode == 404) {
        throw Exception('Todo not found');
      } else {
        throw Exception('Failed to update todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating todo: $e');
    }
  }

  // DELETE todo
  Future<void> deleteTodo(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse(ApiConfig.getTodoUrl(id)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Todo not found');
      } else {
        throw Exception('Failed to delete todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting todo: $e');
    }
  }

  // POST add step to todo
  Future<Todo> addStepToTodo({
    required int todoId,
    required String stepTitle,
  }) async {
    try {
      final body = json.encode({
        'items': stepTitle,
        'completed': false,
      });

      final response = await _client.post(
        Uri.parse(ApiConfig.addStepUrl(todoId)),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
          (data) => Todo.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        }
        throw Exception(apiResponse.error ?? 'Failed to add step');
      } else if (response.statusCode == 404) {
        throw Exception('Todo not found');
      } else {
        throw Exception('Failed to add step: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding step: $e');
    }
  }

  // PATCH update step
  Future<TodoStep> updateStep({
    required int stepId,
    String? title,
    bool? completed,
  }) async {
    try {
      final body = json.encode({
        if (title != null) 'items': title,
        if (completed != null) 'completed': completed,
      });

      final response = await _client.patch(
        Uri.parse(ApiConfig.getStepUrl(stepId)),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
          (data) => TodoStep.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        }
        throw Exception(apiResponse.error ?? 'Failed to update step');
      } else if (response.statusCode == 404) {
        throw Exception('Step not found');
      } else {
        throw Exception('Failed to update step: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating step: $e');
    }
  }

  // DELETE step
  Future<void> deleteStep(int stepId) async {
    try {
      final response = await _client.delete(
        Uri.parse(ApiConfig.getStepUrl(stepId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Step not found');
      } else {
        throw Exception('Failed to delete step: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting step: $e');
    }
  }

  void dispose() {
    _client.close();
  }

  // Voice to text API
  Future<String> voiceToText(String audioBase64, String audioFormat) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.voiceToTextUrl()),
        headers: _headers,
        body: jsonEncode({
          'audioBase64': audioBase64,
          'audioFormat': audioFormat,
        }),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          jsonDecode(response.body),
          (json) => json as Map<String, dynamic>,
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!['text'] as String? ?? '';
        } else {
          throw Exception(apiResponse.message ?? 'Failed to transcribe audio');
        }
      } else {
        throw Exception('Failed to transcribe audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error transcribing audio: $e');
    }
  }

  // Generate tasks from prompt API
  Future<Todo> generateTasks(String prompt, {int? maxTasks}) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.generateTasksUrl()),
        headers: _headers,
        body: jsonEncode({
          'prompt': prompt,
          if (maxTasks != null) 'maxTasks': maxTasks,
        }),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          jsonDecode(response.body),
          (json) => json as Map<String, dynamic>,
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return Todo.fromJson(apiResponse.data!);
        } else {
          throw Exception(apiResponse.message ?? 'Failed to generate tasks');
        }
      } else {
        throw Exception('Failed to generate tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating tasks: $e');
    }
  }
}
