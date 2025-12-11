import TodoList from '../components/todo/TodoList';
import TodoForm from '../components/todo/TodoForm';
import Toast from '../components/common/Toast';
import useTodos from '../hooks/useTodos';
import './TodoPage.css';

export default function TodoPage() {
    const { todos, loading, error, toastMessage, toastType, addTodo, toggleTodo, toggleStep, deleteTodo, updateTodo, deleteStep, clearToast } = useTodos();

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
            <Toast message={toastMessage} type={toastType} onClose={clearToast} />

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
                    deleteStep={deleteStep}
                />

                <TodoForm onAdd={addTodo} />
            </div>
        </div>
    );
}
