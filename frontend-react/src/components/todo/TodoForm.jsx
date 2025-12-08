import { useState } from 'react';
import './TodoForm.css';

export default function TodoForm({ onAdd }) {
    const [text, setText] = useState('');

    const handleSubmit = (e) => {
        e.preventDefault();
        if (text.trim()) {
            onAdd(text.trim());
            setText('');
        }
    };

    return (
        <form className="todo-form" onSubmit={handleSubmit}>
            <input
                type="text"
                className="todo-input"
                placeholder="What needs to be done?"
                value={text}
                onChange={(e) => setText(e.target.value)}
            />
            <button type="submit" className="todo-submit-btn">
                Add Todo
            </button>
        </form>
    );
}
