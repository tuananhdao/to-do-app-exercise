import TodoList from '../components/todo/TodoList';
import TodoForm from '../components/todo/TodoForm';
import useTodos from '../hooks/useTodos';
import './TodoPage.css';

export default function TodoPage() {
    const { todos, loading, error, addTodo, toggleTodo, toggleStep, deleteTodo, updateTodo } = useTodos();

    if (loading) {
        return (
            <div className="todo-page">
                <div className="todo-container">
                    <div className="loading-message">Loading todos...</div>
                </div>
            </div>
        );
    }

    return (
        <div className="todo-page">
            <div className="todo-container">
                {error && (
                    <div className="error-message" style={{
                        padding: '10px',
                        marginBottom: '10px',
                        backgroundColor: '#fee',
                        color: '#c33',
                        borderRadius: '4px'
                    }}>
                        Error: {error}
                    </div>
                )}

                <TodoList
                    todos={todos}
                    onToggle={toggleTodo}
                    onToggleStep={toggleStep}
                    onDelete={deleteTodo}
                    onUpdate={updateTodo}
                />

                <TodoForm onAdd={addTodo} />
            </div>
        </div>
    );
}
