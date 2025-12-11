import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'config/constants.dart';
import 'models/todo.dart';
import 'widgets/todo_tile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('BASE_URL: $BASE_URL');
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<Todo> _todos = [
    Todo(
      id: '1',
      title: 'Todo Title 1',
      steps: [
        TodoStep(id: '1-1', title: 'mua rau'),
        TodoStep(id: '1-2', title: 'mua thịt', completed: true),
      ],
    ),
    Todo(
      id: '2',
      title: 'Todo Title 2',
      steps: [
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
        title: const Text(
          'AppBar: Todo List',
          style: TextStyle(color: Colors.black87, fontSize: 16),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return TodoTile(
                  todo: todo,
                  onToggleTodo: (value) => _toggleTodo(todo, value),
                  onToggleStep: (step, value) =>
                      _toggleStep(todo: todo, step: step, value: value),
                  onAddStep: () => _addStep(todo),
                  onEdit: () => _showEditDialog(todo),
                  onDelete: () => _deleteTodo(todo),
                );
              },
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.shade300,
              ),
              itemCount: _todos.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _toggleTodo(Todo todo, bool value) {
    setState(() {
      todo.steps = todo.steps
          .map((step) => TodoStep(
                id: step.id,
                title: step.title,
                completed: value,
              ))
          .toList();
    });
  }

  void _toggleStep({
    required Todo todo,
    required TodoStep step,
    required bool value,
  }) {
    setState(() {
      step.completed = value;
    });
  }

  Future<void> _addStep(Todo todo) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add step'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Step title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      setState(() {
        todo.steps.add(
          TodoStep(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: controller.text.trim(),
          ),
        );
      });
    }
  }

  void _deleteTodo(Todo todo) {
    setState(() {
      _todos.removeWhere((t) => t.id == todo.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todo deleted')),
    );
  }

  void _showAddDialog() {
    _openTodoDialog();
  }

  void _showEditDialog(Todo todo) {
    _openTodoDialog(existing: todo);
  }

  Future<void> _openTodoDialog({Todo? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add Todo' : 'Edit Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != true) return;
    if (titleController.text.trim().isEmpty) return;

    setState(() {
      if (existing != null) {
        existing.title = titleController.text.trim();
      } else {
        _todos.add(
          Todo(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: titleController.text.trim(),
            steps: [],
          ),
        );
      }
    });
  }
}

