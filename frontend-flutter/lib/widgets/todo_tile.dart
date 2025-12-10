import 'package:flutter/material.dart';

import '../models/todo.dart';

class TodoTile extends StatefulWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggleTodo,
    required this.onToggleStep,
    required this.onAddStep,
    required this.onEdit,
    required this.onDelete,
  });

  final Todo todo;
  final ValueChanged<bool> onToggleTodo;
  final void Function(TodoStep step, bool value) onToggleStep;
  final VoidCallback onAddStep;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.todo.id),
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: Colors.blue.shade100,
        icon: Icons.edit,
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: Colors.red.shade100,
        icon: Icons.delete,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          widget.onEdit();
          return false;
        }
        widget.onDelete();
        return true;
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: const Border(),
        child: ExpansionTile(
          initiallyExpanded: false,
          onExpansionChanged: (value) {
            setState(() => _expanded = value);
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 12,
            bottom: 12,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add step',
                onPressed: widget.onAddStep,
              ),
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _expanded ? 0.5 : 0,
                child: const Icon(Icons.expand_more),
              ),
            ],
          ),
          leading: Checkbox(
            value: widget.todo.isCompleted,
            onChanged: (value) => widget.onToggleTodo(value ?? false),
          ),
          title: Text(
            widget.todo.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          children: [
            ...widget.todo.steps.map(
              (step) => CheckboxListTile(
                value: step.completed,
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(step.title),
                onChanged: (value) =>
                    widget.onToggleStep(step, value ?? false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: alignment,
      child: Icon(icon, color: Colors.black54),
    );
  }
}

