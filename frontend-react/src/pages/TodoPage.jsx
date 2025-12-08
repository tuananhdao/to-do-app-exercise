import { useState } from 'react';
import TodoList from '../components/todo/TodoList';
import TodoForm from '../components/todo/TodoForm';
import TodoFilter from '../components/todo/TodoFilter';
import useTodos from '../hooks/useTodos';
import './TodoPage.css';

export default function TodoPage() {
    const { todos, addTodo, toggleTodo, deleteTodo, updateTodo } = useTodos();
    const [filter, setFilter] = useState('all');

    const filteredTodos = todos.filter(todo => {
        if (filter === 'active') return !todo.completed;
        if (filter === 'completed') return todo.completed;
        return true;
    });

    const stats = {
        total: todos.length,
        active: todos.filter(t => !t.completed).length,
        completed: todos.filter(t => t.completed).length,
    };

    return (
        <div className="todo-page">
            <div className="page-header">
                <h1>📋 All Todos</h1>
                <div className="stats">
                    <span className="stat-item">Total: {stats.total}</span>
                    <span className="stat-item">Active: {stats.active}</span>
                    <span className="stat-item">Completed: {stats.completed}</span>
                </div>
            </div>

            <TodoForm onAdd={addTodo} />
            <TodoFilter currentFilter={filter} onFilterChange={setFilter} />
            <TodoList
                todos={filteredTodos}
                onToggle={toggleTodo}
                onDelete={deleteTodo}
                onUpdate={updateTodo}
            />
        </div>
    );
}
