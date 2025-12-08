import { useState } from 'react';
import './TodoItem.css';

export default function TodoItem({ todo, onToggle, onDelete, onUpdate }) {
    const [isEditing, setIsEditing] = useState(false);
    const [editText, setEditText] = useState(todo.text);

    const handleUpdate = () => {
        if (editText.trim() && editText !== todo.text) {
            onUpdate(todo.id, editText.trim());
        }
        setIsEditing(false);
    };

    const handleCancel = () => {
        setEditText(todo.text);
        setIsEditing(false);
    };

    return (
        <div className={`todo-item ${todo.completed ? 'completed' : ''}`}>
            <input
                type="checkbox"
                className="todo-checkbox"
                checked={todo.completed}
                onChange={() => onToggle(todo.id)}
            />

            {isEditing ? (
                <div className="edit-container">
                    <input
                        type="text"
                        className="edit-input"
                        value={editText}
                        onChange={(e) => setEditText(e.target.value)}
                        onKeyDown={(e) => {
                            if (e.key === 'Enter') handleUpdate();
                            if (e.key === 'Escape') handleCancel();
                        }}
                        autoFocus
                    />
                    <div className="edit-actions">
                        <button onClick={handleUpdate} className="btn-save">
                            Save
                        </button>
                        <button onClick={handleCancel} className="btn-cancel">
                            Cancel
                        </button>
                    </div>
                </div>
            ) : (
                <>
                    <span className="todo-text">{todo.text}</span>
                    <div className="todo-actions">
                        <button
                            onClick={() => setIsEditing(true)}
                            className="btn-edit"
                            title="Edit"
                        >
                            ✏️
                        </button>
                        <button
                            onClick={() => onDelete(todo.id)}
                            className="btn-delete"
                            title="Delete"
                        >
                            🗑️
                        </button>
                    </div>
                </>
            )}
        </div>
    );
}
