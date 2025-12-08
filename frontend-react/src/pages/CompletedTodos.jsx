import TodoList from '../components/todo/TodoList';
import useTodos from '../hooks/useTodos';

export default function CompletedTodos() {
    const { todos, toggleTodo, deleteTodo, updateTodo } = useTodos();
    const completedTodos = todos.filter(todo => todo.completed);

    return (
        <div className="todo-page">
            <div className="page-header">
                <h1>✅ Completed Todos</h1>
                <p style={{ color: '#718096', marginTop: '0.5rem' }}>
                    You have completed {completedTodos.length} {completedTodos.length === 1 ? 'task' : 'tasks'}
                </p>
            </div>

            <TodoList
                todos={completedTodos}
                onToggle={toggleTodo}
                onDelete={deleteTodo}
                onUpdate={updateTodo}
            />

            {completedTodos.length === 0 && (
                <div style={{
                    textAlign: 'center',
                    padding: '3rem',
                    color: '#a0aec0',
                    background: 'white',
                    borderRadius: '12px'
                }}>
                    <p style={{ fontSize: '1.2rem' }}>📝 No completed tasks yet. Start checking off your list!</p>
                </div>
            )}
        </div>
    );
}
