import TodoList from '../components/todo/TodoList';
import TodoForm from '../components/todo/TodoForm';
import useTodos from '../hooks/useTodos';
import './TodoPage.css';

export default function TodoPage() {
    const { todos, addTodo, toggleTodo, toggleStep, deleteTodo, updateTodo } = useTodos();

    return (
        <div className="todo-page">
            <TodoList
                todos={todos}
                onToggle={toggleTodo}
                onToggleStep={toggleStep}
                onDelete={deleteTodo}
                onUpdate={updateTodo}
            />

            <TodoForm onAdd={addTodo} />
        </div>
    );
}
