class TodoStep {
  TodoStep({
    this.id,
    required this.title,
    this.completed = false,
  });

  final int? id;
  final String title;
  bool completed;
  
  // Alias for title to match widget usage
  String get items => title;

  // JSON serialization
  factory TodoStep.fromJson(Map<String, dynamic> json) {
    return TodoStep(
      id: json['id'] as int?,
      title: json['items'] as String? ?? json['title'] as String,
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'items': title,
      'completed': completed,
    };
  }

  TodoStep copyWith({
    int? id,
    String? title,
    bool? completed,
  }) {
    return TodoStep(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}

class Todo {
  Todo({
    this.id,
    required this.title,
    this.steps = const [],
    this.createdAt,
  });

  final int? id;
  String title;
  List<TodoStep> steps;
  final DateTime? createdAt;

  bool get isCompleted => steps.isNotEmpty && steps.every((s) => s.completed);
  bool get completed => isCompleted;

  // JSON serialization
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int?,
      title: json['title'] as String,
      steps: (json['steps'] as List<dynamic>?)
              ?.map((step) => TodoStep.fromJson(step as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'completed': completed,
      'steps': steps.map((step) => step.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  Todo copyWith({
    int? id,
    String? title,
    List<TodoStep>? steps,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

