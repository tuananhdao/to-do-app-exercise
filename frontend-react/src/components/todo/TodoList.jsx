import TodoItem from './TodoItem';

export default function TodoList({ todos, onToggle, onToggleStep, onUpdateStep, onDelete, onUpdate, onAddItem, onDeleteStep }) {
    if (todos.length === 0) {
        return (
            <div className="card p-12 text-center">
                <div className="text-6xl mb-4">📝</div>
                <p className="text-gray-500">Chưa có công việc nào. Hãy thêm công việc mới!</p>
            </div>
        );
    }

    const ordered = [...todos].sort((a, b) => {
        if (a.completed !== b.completed) return a.completed ? 1 : -1;
        return new Date(a.createdAt || 0) - new Date(b.createdAt || 0);
    });

    return (
        <div className="space-y-2">
            {ordered.map(todo => (
                <TodoItem
                    key={todo.id}
                    todo={todo}
                    onToggle={onToggle}
                    onToggleStep={onToggleStep}
                    onUpdateStep={onUpdateStep}
                    onDelete={onDelete}
                    onUpdate={onUpdate}
                    onAddItem={onAddItem}
                    onDeleteStep={onDeleteStep}
                />
            ))}
        </div>
    );
}
