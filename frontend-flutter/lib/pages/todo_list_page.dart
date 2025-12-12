import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore_for_file: use_build_context_synchronously

import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';
import '../widgets/voice_input_dialog.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TodoProvider>().fetchTodos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEAF1FB),
                Color(0xFFDCE7F7),
              ],
            ),
          ),
        ),
        title: const Text(
          'Todo List',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, _) {
          if (todoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (todoProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${todoProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => todoProvider.fetchTodos(),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (todoProvider.todos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Chưa có todo nào',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: todoProvider.fetchTodos,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              itemCount: todoProvider.todos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final todo = todoProvider.todos[index];
                return TodoTile(
                  todo: todo,
                  onToggleTodo: () => todoProvider.toggleTodo(todo.id!),
                  onToggleStep: (TodoStep step) =>
                      todoProvider.toggleStep(step.id!),
                  onEditStep: (TodoStep step) =>
                      _showEditStepDialog(step, todoProvider),
                  onConfirmDelete: () => _confirmDeleteTodo(todo),
                  onEdit: () => _showEditTitleDialog(todo),
                  onAddStep: () => _showAddStepDialog(todo, todoProvider),
                  onDeleteStep: (TodoStep step) =>
                      todoProvider.deleteStep(step.id!),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'mic-fab',
            mini: true,
            tooltip: 'Voice input / AI Task Generator',
            onPressed: _showVoiceInputDialog,
            foregroundColor: const Color(0xFF3E5F8A),
            child: const Icon(Icons.mic_none),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add-fab',
            onPressed: _showAddDialog,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final titleController = TextEditingController();
    final stepsController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stepsController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Steps (one per line)',
              ),
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
    final title = titleController.text.trim();
    if (title.isEmpty) return;

    final steps = stepsController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    await context.read<TodoProvider>().addTodo(title, steps);
  }

  Future<void> _showEditTitleDialog(Todo todo) async {
    final titleController = TextEditingController(text: todo.title);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Title'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title'),
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

    if (result == true && titleController.text.trim().isNotEmpty) {
      await context
          .read<TodoProvider>()
          .updateTodoTitle(todo.id!, titleController.text.trim());
    }
  }

  /// Show voice input dialog for AI-powered task generation
  Future<void> _showVoiceInputDialog() async {
    final result = await showDialog<Todo>(
      context: context,
      builder: (context) => const VoiceInputDialog(),
    );

    // If a todo was generated (returned from dialog), refresh the list
    if (result != null) {
      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Todo "${result.title}" đã được tạo thành công!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Refresh the todo list to show the newly created todo
      await context.read<TodoProvider>().fetchTodos();
    }
  }

  Future<bool> _confirmDeleteTodo(Todo todo) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!mounted) return false;
      await context.read<TodoProvider>().deleteTodo(todo.id!);
    }
    return false;
  }

  Future<void> _showEditStepDialog(
    TodoStep step,
    TodoProvider provider,
  ) async {
    final controller = TextEditingController(text: step.items);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa task con'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nội dung'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      await provider.updateStepText(step.id!, controller.text.trim());
    }
  }

  Future<void> _showAddStepDialog(
    Todo todo,
    TodoProvider provider,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm task con'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nội dung'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      try {
        await provider.addStepToTodo(todo.id!, controller.text.trim());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm task con')),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi thêm task con')),
        );
      }
    }
  }
}
