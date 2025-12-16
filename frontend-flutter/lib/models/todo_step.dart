class TodoStep {
  final int id;
  final String items;
  final bool completed;

  const TodoStep({
    required this.id,
    required this.items,
    required this.completed,
  });

  factory TodoStep.fromJson(Map<String, dynamic> json) {
    return TodoStep(
      id: json['id'] as int,
      items: json['items'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'completed': completed,
    };
  }
}





