import 'package:flutter/material.dart';

import '../config/app_theme.dart';
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

class _TodoTileState extends State<TodoTile> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.todo.completed;
    final completedSteps = widget.todo.steps.where((s) => s.completed).length;
    final totalSteps = widget.todo.steps.length;
    
    return Dismissible(
      key: ValueKey(widget.todo.id),
      direction: isCompleted ? DismissDirection.none : DismissDirection.horizontal,
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.1),
            AppTheme.primary.withOpacity(0.05),
          ],
        ),
        icon: Icons.edit_rounded,
        iconColor: AppTheme.primary,
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        gradient: LinearGradient(
          colors: [
            AppTheme.error.withOpacity(0.05),
            AppTheme.error.withOpacity(0.1),
          ],
        ),
        icon: Icons.delete_rounded,
        iconColor: AppTheme.error,
      ),
      confirmDismiss: (direction) async {
        if (isCompleted) return false;
        if (direction == DismissDirection.startToEnd) {
          widget.onEdit();
          return false;
        }
        return await widget.onConfirmDelete();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompleted 
                ? AppTheme.success.withOpacity(0.2)
                : AppTheme.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            children: [
              // Header
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: totalSteps > 0 ? () {
                    setState(() {
                      _expanded = !_expanded;
                      if (_expanded) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                    });
                  } : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkbox - Microsoft To Do style
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isCompleted ? AppTheme.primary : Colors.transparent,
                              border: Border.all(
                                color: isCompleted ? AppTheme.primary : AppTheme.textTertiary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: InkWell(
                              onTap: () => widget.onToggleTodo(),
                              borderRadius: BorderRadius.circular(20),
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Title and Progress
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.todo.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isCompleted
                                      ? AppTheme.textTertiary
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              if (totalSteps > 0) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 14,
                                      color: completedSteps == totalSteps
                                          ? AppTheme.success
                                          : AppTheme.textTertiary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$completedSteps of $totalSteps',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: completedSteps == totalSteps
                                            ? AppTheme.success
                                            : AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // Action Buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (totalSteps > 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: RotationTransition(
                                  turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                                  child: Icon(
                                    Icons.chevron_right,
                                    color: AppTheme.textTertiary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                color: isCompleted
                                    ? AppTheme.textTertiary
                                    : AppTheme.textSecondary,
                                size: 20,
                              ),
                              onPressed: isCompleted ? null : widget.onAddStep,
                              tooltip: 'Add step',
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Steps List
              if (totalSteps > 0)
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.border,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: widget.todo.steps.length,
                      itemBuilder: (context, index) {
                        final step = widget.todo.steps[index];
                        return _buildStepItem(step, isCompleted);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(TodoStep step, bool todoCompleted) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onToggleStep(step),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox - smaller for substeps
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 32),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: step.completed ? AppTheme.primary : Colors.transparent,
                    border: Border.all(
                      color: step.completed ? AppTheme.primary : AppTheme.textTertiary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: step.completed
                      ? const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              
              // Step Text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    step.items,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      decoration: step.completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: step.completed
                          ? AppTheme.textTertiary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              
              // Actions - compact
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: todoCompleted
                          ? AppTheme.textTertiary
                          : AppTheme.textSecondary,
                    ),
                    onPressed: todoCompleted ? null : () => widget.onEditStep(step),
                    tooltip: 'Edit',
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 16,
                      color: todoCompleted
                          ? AppTheme.textTertiary
                          : AppTheme.textSecondary,
                    ),
                    onPressed: todoCompleted ? null : () => widget.onDeleteStep(step),
                    tooltip: 'Delete',
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Gradient gradient,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}
