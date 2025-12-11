import 'package:flutter/material.dart';

import '../models/todo.dart';

class TodoTile extends StatefulWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggleTodo,
    required this.onToggleStep,
    required this.onEditStep,
    required this.onConfirmDelete,
    required this.onEdit,
    required this.onAddStep,
    required this.onDeleteStep,
  });

  final Todo todo;
  final VoidCallback onToggleTodo;
  final void Function(TodoStep step) onToggleStep;
  final void Function(TodoStep step) onEditStep;
  final Future<bool> Function() onConfirmDelete;
  final VoidCallback onEdit;
  final VoidCallback onAddStep;
  final void Function(TodoStep step) onDeleteStep;

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.todo.completed;
    
    return Dismissible(
      key: ValueKey(widget.todo.id),
      // Disable swipe actions when completed
      direction: isCompleted ? DismissDirection.none : DismissDirection.horizontal,
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
        if (isCompleted) return false; // Extra safety check
        if (direction == DismissDirection.startToEnd) {
          widget.onEdit();
          return false;
        }
        return await widget.onConfirmDelete();
      },
      child: Card(
        child: ExpansionTile(
          initiallyExpanded: false,
          maintainState: true,
          onExpansionChanged: (value) {
            setState(() => _expanded = value);
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 12,
            bottom: 12,
          ),
          trailing: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _expanded ? 0.5 : 0,
            child: const Icon(Icons.expand_more),
          ),
          leading: Checkbox(
            value: widget.todo.completed,
            onChanged: (_) => widget.onToggleTodo(),
            activeColor: const Color(0xFF3E5F8A),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  widget.todo.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: widget.todo.completed
                        ? Colors.grey.shade500
                        : const Color(0xFF1F2937),
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.add,
                  color: isCompleted ? Colors.grey.shade400 : null,
                ),
                tooltip: isCompleted ? 'Không thể thêm step (đã hoàn thành)' : 'Thêm task con',
                onPressed: isCompleted ? null : widget.onAddStep,
              ),
            ],
          ),
          subtitle: widget.todo.createdAt != null
              ? Text(
                  'Created: ${widget.todo.createdAt}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
              : null,
          children: [
            ...widget.todo.steps.map(
              (step) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: step.completed
                      ? const Color(0xFFF0F2F6)
                      : const Color(0xFFEEF5FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CheckboxListTile(
                  value: step.completed,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    step.items,
                    style: TextStyle(
                      decoration: step.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: step.completed
                          ? Colors.grey.shade600
                          : const Color(0xFF111827),
                    ),
                  ),
                  onChanged: (_) => widget.onToggleStep(step),
                  secondary: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit, 
                          size: 18,
                          color: isCompleted ? Colors.grey.shade400 : null,
                        ),
                        tooltip: isCompleted ? 'Không thể sửa (đã hoàn thành)' : 'Sửa step',
                        onPressed: isCompleted ? null : () => widget.onEditStep(step),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete, 
                          size: 18,
                          color: isCompleted ? Colors.grey.shade400 : Colors.red.shade300,
                        ),
                        tooltip: isCompleted ? 'Không thể xóa (đã hoàn thành)' : 'Xóa step',
                        onPressed: isCompleted ? null : () => widget.onDeleteStep(step),
                      ),
                    ],
                  ),
                ),
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

