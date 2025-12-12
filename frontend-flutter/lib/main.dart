import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'models/todo.dart';
import 'providers/todo_provider.dart';
import 'widgets/todo_tile.dart';
import 'widgets/voice_input_dialog.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo List',
        theme: AppTheme.lightTheme,
        home: const TodoHomePage(),
      ),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch todos when the page loads
    Future.microtask(() {
      context.read<TodoProvider>().fetchTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('My Tasks'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<TodoProvider>().fetchTodos(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading tasks...',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Oops! Something went wrong',
                      style: AppTheme.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: AppTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.fetchTodos(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final todos = provider.todos;

          if (todos.isEmpty) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient.scale(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.task_alt_rounded,
                        size: 80,
                        color: AppTheme.primary.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No tasks yet!',
                      style: AppTheme.h2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button below to create your first task\nor use AI to generate tasks from your voice',
                      style: AppTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: provider.fetchTodos,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 100, bottom: 100),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return TodoTile(
                        todo: todo,
                        onToggleTodo: () => _toggleTodo(context, todo),
                        onToggleStep: (step) => _toggleStep(context, step),
                        onEditStep: (step) => _editStep(context, step),
                        onConfirmDelete: () => _confirmDelete(context, todo),
                        onEdit: () => _showEditDialog(context, todo),
                        onAddStep: () => _addStep(context, todo),
                        onDeleteStep: (step) => _deleteStep(context, step),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'ai_button',
              onPressed: () => _showAIDialog(context),
              child: const Icon(Icons.auto_awesome_rounded, size: 22),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'add_button',
              onPressed: () => _showAddDialog(context),
              child: const Icon(Icons.add_rounded, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTodo(BuildContext context, Todo todo) async {
    if (todo.id == null) return;
    
    try {
      await context.read<TodoProvider>().toggleTodo(todo.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todo updated')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _toggleStep(BuildContext context, TodoStep step) async {
    if (step.id == null) return;

    try {
      await context.read<TodoProvider>().toggleStep(step.id!);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _editStep(BuildContext context, TodoStep step) async {
    if (step.id == null) return;

    final controller = TextEditingController(text: step.title);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit step'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty && context.mounted) {
      try {
        await context.read<TodoProvider>().updateStepText(
          step.id!,
          controller.text.trim(),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Step updated')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _addStep(BuildContext context, Todo todo) async {
    if (todo.id == null) return;

    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm task con'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nội dung task',
            hintText: 'Nhập nội dung task con...',
          ),
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

    if (result == true && controller.text.trim().isNotEmpty && context.mounted) {
      try {
        await context.read<TodoProvider>().addStepToTodo(
          todo.id!,
          controller.text.trim(),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã thêm task con')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteStep(BuildContext context, TodoStep step) async {
    if (step.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa task con'),
        content: Text('Bạn có chắc muốn xóa "${step.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<TodoProvider>().deleteStep(step.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa task con')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  void _deleteTodo(BuildContext context, Todo todo) async {
    if (todo.id == null) return;

    try {
      await context.read<TodoProvider>().deleteTodo(todo.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todo deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<bool> _confirmDelete(BuildContext context, Todo todo) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      _deleteTodo(context, todo);
      return true;
    }
    return false;
  }

  void _showAddDialog(BuildContext context) {
    _openTodoDialog(context);
  }

  void _showEditDialog(BuildContext context, Todo todo) {
    _openTodoDialog(context, existing: todo);
  }

  Future<void> _showAIDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => const VoiceInputDialog(),
    );

    if (result != null && context.mounted) {
      // The AI already saved the task to backend, just refresh the list
      await context.read<TodoProvider>().fetchTodos();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI task generated successfully')),
        );
      }
    }
  }

  Future<void> _openTodoDialog(BuildContext context, {Todo? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    
    // For new todos, manage multiple step inputs
    final stepControllers = <TextEditingController>[];
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _TodoDialogWidget(
        titleController: titleController,
        stepControllers: stepControllers,
        isEditMode: existing != null,
      ),
    );

    if (result != true || !context.mounted) {
      // Dispose controllers
      for (var controller in stepControllers) {
        controller.dispose();
      }
      return;
    }
    
    if (titleController.text.trim().isEmpty) {
      for (var controller in stepControllers) {
        controller.dispose();
      }
      return;
    }

    try {
      if (existing != null && existing.id != null) {
        // Update existing todo
        await context.read<TodoProvider>().updateTodoTitle(
          existing.id!,
          titleController.text.trim(),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todo updated')),
          );
        }
      } else {
        // Create new todo
        final steps = stepControllers
            .map((c) => c.text.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        await context.read<TodoProvider>().addTodo(
          titleController.text.trim(),
          steps,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todo added')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      // Dispose controllers
      titleController.dispose();
      for (var controller in stepControllers) {
        controller.dispose();
      }
    }
  }
}

class _TodoDialogWidget extends StatefulWidget {
  const _TodoDialogWidget({
    required this.titleController,
    required this.stepControllers,
    required this.isEditMode,
  });

  final TextEditingController titleController;
  final List<TextEditingController> stepControllers;
  final bool isEditMode;

  @override
  State<_TodoDialogWidget> createState() => _TodoDialogWidgetState();
}

class _TodoDialogWidgetState extends State<_TodoDialogWidget> {
  @override
  void initState() {
    super.initState();
    // Start with one empty step field for new todos
    if (!widget.isEditMode) {
      widget.stepControllers.add(TextEditingController());
    }
  }

  void _addStepField() {
    setState(() {
      widget.stepControllers.add(TextEditingController());
    });
  }

  void _removeStepField(int index) {
    setState(() {
      widget.stepControllers[index].dispose();
      widget.stepControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditMode ? 'Edit Todo' : 'Add Todo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter todo title',
              ),
              autofocus: true,
            ),
            if (!widget.isEditMode) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Steps (optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    tooltip: 'Add step',
                    color: Theme.of(context).primaryColor,
                    onPressed: _addStepField,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(
                widget.stepControllers.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.stepControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Step ${index + 1}',
                            hintText: 'Enter step description',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        tooltip: 'Remove step',
                        color: Colors.red,
                        onPressed: widget.stepControllers.length > 1
                            ? () => _removeStepField(index)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
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
    );
  }
}

