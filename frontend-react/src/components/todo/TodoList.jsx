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

    return (
        <div className="todo-list">
            {todos.map(todo => (
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
