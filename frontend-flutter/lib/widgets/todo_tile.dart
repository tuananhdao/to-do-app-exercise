import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../models/todo_step.dart';

class TodoTile extends StatefulWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggleTodo,
    required this.onToggleStep,
    required this.onEditStep,
    required this.onConfirmDelete,
    required this.onEdit,
  });

  final Todo todo;
  final VoidCallback onToggleTodo;
  final void Function(TodoStep step) onToggleStep;
  final void Function(TodoStep step) onEditStep;
  final Future<bool> Function() onConfirmDelete;
  final VoidCallback onEdit;

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final stepsDone =
        widget.todo.steps.where((step) => step.completed).length;
    final stepsTotal = widget.todo.steps.length;

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
        return await widget.onConfirmDelete();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7FBFF),
              Color(0xFFE9F4FF),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x332196F3),
              blurRadius: 18,
              offset: Offset(0, 12),
            ),
          ],
          border: Border.all(
            color: widget.todo.completed
                ? const Color(0xFF22C55E).withOpacity(0.35)
                : const Color(0xFF0EA5E9).withOpacity(0.30),
            width: 1.0,
          ),
        ),
        child: ExpansionTile(
          collapsedIconColor: const Color(0xFF0F172A),
          iconColor: const Color(0xFF0F172A),
          initiallyExpanded: false,
          maintainState: true,
          onExpansionChanged: (value) {
            setState(() => _expanded = value);
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          childrenPadding: const EdgeInsets.only(
            left: 14,
            right: 12,
            bottom: 14,
          ),
          trailing: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _expanded ? 0.5 : 0,
            child: const Icon(Icons.expand_more, color: Color(0xFF0F172A)),
          ),
          leading: Checkbox(
            value: widget.todo.completed,
            onChanged: (_) => widget.onToggleTodo(),
            activeColor: const Color(0xFF0EA5E9),
            checkColor: Colors.white,
            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.todo.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: const Color(0xFF0F172A),
                        decoration: widget.todo.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: const Color(0xFF94A3B8),
                      ),
                    ),
                    if (widget.todo.createdAt != null)
                      Text(
                        'Created: ${widget.todo.createdAt}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.todo.completed
                          ? Icons.check_circle
                          : Icons.timelapse,
                      size: 16,
                      color: widget.todo.completed
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF0EA5E9),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$stepsDone/$stepsTotal',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            ...widget.todo.steps.map(
              (step) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: step.completed
                      ? const Color(0xFFDBEAFE) // soft indigo tint
                      : const Color(0xFFE0F2FE), // light sky tint
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: step.completed
                        ? const Color(0xFF6366F1).withOpacity(0.35)
                        : const Color(0xFF7DD3FC).withOpacity(0.45),
                  ),
                ),
                child: CheckboxListTile(
                  value: step.completed,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFF0EA5E9),
                  checkColor: Colors.white,
                  title: Text(
                    step.items,
                    style: TextStyle(
                      decoration: step.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: step.completed
                          ? const Color(0xFF4B5563)
                          : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onChanged: (_) => widget.onToggleStep(step),
                  secondary: IconButton(
                    icon: const Icon(Icons.edit,
                        size: 18, color: Color(0xFF0F172A)),
                    tooltip: 'Sửa step',
                    onPressed: () => widget.onEditStep(step),
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

