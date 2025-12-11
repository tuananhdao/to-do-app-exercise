import TodoItem from './TodoItem';
import './TodoList.css';

export default function TodoList({ todos, onToggle, onToggleStep, onDelete, onUpdate }) {
    if (todos.length === 0) {
        return (
            <div className="empty-state">
                <div className="empty-icon">📝</div>
                <p>No todos yet. Add one above to get started!</p>
            </div>
        );
    }

    const ordered = [...todos].sort((a, b) => {
        if (a.completed !== b.completed) return a.completed ? 1 : -1; // completed xuống cuối
        return new Date(a.createdAt || 0) - new Date(b.createdAt || 0);
    });

    return (
        <div className="todo-list">
            {ordered.map(todo => (
                <TodoItem
                    key={todo.id}
                    todo={todo}
                    onToggle={onToggle}
                    onToggleStep={onToggleStep}
                    onDelete={onDelete}
                    onUpdate={onUpdate}
                />
            ))}
        </div>
    );
}
