class ApiConfig {
  // Backend API base URL
  // For Android emulator use: http://10.0.2.2:8080
  // For iOS simulator use: http://localhost:8080
  // For physical device use your computer's IP: http://192.168.x.x:8080
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = '/api/v1';
  
  // Endpoints
  static const String todosEndpoint = '$apiVersion/todos';
  static const String voiceToTextEndpoint = '$apiVersion/voice-to-text';
  static const String generateTasksEndpoint = '$apiVersion/generate-tasks';
  
  // Helper methods
  static String getTodosUrl() => '$baseUrl$todosEndpoint';
  static String getTodoUrl(int id) => '$baseUrl$todosEndpoint/$id';
  static String getStepUrl(int stepId) => '$baseUrl$todosEndpoint/items/$stepId';
  static String addStepUrl(int todoId) => '$baseUrl$todosEndpoint/$todoId/items';
  static String voiceToTextUrl() => '$baseUrl$voiceToTextEndpoint';
  static String generateTasksUrl() => '$baseUrl$generateTasksEndpoint';
}
