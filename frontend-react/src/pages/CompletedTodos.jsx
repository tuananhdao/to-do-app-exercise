import TodoList from '../components/todo/TodoList';
import useTodos from '../hooks/useTodos';

export default function CompletedTodos() {
    const { todos, loading, error, toggleTodo, toggleStep, deleteTodo, updateTodo, addItemToTodo, deleteStepFromTodo } = useTodos();
    const completedTodos = todos.filter(todo => todo.completed);

    if (loading) {
        return (
            <div className="todo-page">
                <div className="page-header">
                    <h1>✅ Completed Todos</h1>
                </div>
                <div className="loading-message">Loading todos...</div>
            </div>
        );
    }

    return (
        <div className="todo-page">
            <div className="page-header">
                <h1>✅ Completed Todos</h1>
                <p style={{ color: '#718096', marginTop: '0.5rem' }}>
                    You have completed {completedTodos.length} {completedTodos.length === 1 ? 'task' : 'tasks'}
                </p>
                {error && (
                    <div style={{ padding: '10px', marginTop: '10px', backgroundColor: '#fee', color: '#c33', borderRadius: '4px' }}>
                        Error: {error}
                    </div>
                )}
            </div>

            <TodoList
                todos={completedTodos}
                onToggle={toggleTodo}
                onToggleStep={toggleStep}
                onDelete={deleteTodo}
                onUpdate={updateTodo}
                onAddItem={addItemToTodo}
                onDeleteStep={deleteStepFromTodo}
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
