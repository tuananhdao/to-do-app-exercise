class TodoStep {
  TodoStep({
    required this.id,
    required this.title,
    this.completed = false,
  });

  final String id;
  final String title;
  bool completed;
}

class Todo {
  Todo({
    required this.id,
    required this.title,
    this.steps = const [],
  });

  final String id;
  String title;
  List<TodoStep> steps;

  bool get isCompleted => steps.isNotEmpty && steps.every((s) => s.completed);
}

