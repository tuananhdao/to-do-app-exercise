import { useState } from 'react';
import './TodoItem.css';

export default function TodoItem({ todo, onToggle, onToggleStep, onDelete, onUpdate }) {
    const [isEditing, setIsEditing] = useState(false);
    const [editText, setEditText] = useState(todo.text);
    const [editSteps, setEditSteps] = useState(
        todo.steps && todo.steps.length > 0 ? todo.steps.map(s => s.text) : []
    );

    const handleUpdate = () => {
        if (editText.trim()) {
            onUpdate(todo.id, editText.trim(), editSteps.filter(s => s.trim()));
            setIsEditing(false);
        }
    };

    const handleCancel = () => {
        setEditText(todo.text);
        setEditSteps(todo.steps && todo.steps.length > 0 ? todo.steps.map(s => s.text) : []);
        setIsEditing(false);
    };

    const updateStepText = (index, value) => {
        const newSteps = [...editSteps];
        newSteps[index] = value;
        setEditSteps(newSteps);
    };

    const addStepInput = () => {
        setEditSteps([...editSteps, '']);
    };

    const removeStepInput = (index) => {
        setEditSteps(editSteps.filter((_, i) => i !== index));
    };

    const hasSteps = todo.steps && todo.steps.length > 0;

    return (
        <div className={`todo-item ${todo.completed ? 'completed' : ''}`}>
            {isEditing ? (
                <div className="edit-mode">
                    <input
                        type="text"
                        className="edit-todo-input"
                        value={editText}
                        onChange={(e) => setEditText(e.target.value)}
                        placeholder="Todo text"
                        autoFocus
                    />

                    <div className="edit-steps-section">
                        <div className="steps-label">Steps (optional):</div>
                        {editSteps.map((step, index) => (
                            <div key={index} className="edit-step-row">
                                <input
                                    type="text"
                                    className="edit-step-input"
                                    value={step}
                                    onChange={(e) => updateStepText(index, e.target.value)}
                                    placeholder={`Step ${index + 1}`}
                                />
                                <button
                                    type="button"
                                    className="btn-remove-step"
                                    onClick={() => removeStepInput(index)}
                                >
                                    ×
                                </button>
                            </div>
                        ))}
                        <button
                            type="button"
                            className="btn-add-step-inline"
                            onClick={addStepInput}
                        >
                            Add Step
                        </button>
                    </div>

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
                    {/* Todo header */}
                    <div className="todo-header">
                        <input
                            type="checkbox"
                            className="todo-checkbox"
                            checked={todo.completed}
                            onChange={() => onToggle(todo.id)}
                        />
                        <span className="todo-text">{todo.text}</span>
                        <div className="todo-actions">
                            <button
                                onClick={() => setIsEditing(true)}
                                className="btn-edit"
                                title="Edit"
                            >
                                Edit
                            </button>
                            <button
                                onClick={() => onDelete(todo.id)}
                                className="btn-delete"
                                title="Delete"
                            >
                                Delete
                            </button>
                        </div>
                    </div>

                    {/* Steps - only show if exists */}
                    {hasSteps && (
                        <div className="todo-steps">
                            {todo.steps.map(step => (
                                <div key={step.id} className="step-item">
                                    <input
                                        type="checkbox"
                                        className="step-checkbox"
                                        checked={step.completed}
                                        onChange={() => onToggleStep(todo.id, step.id)}
                                    />
                                    <span className={`step-text ${step.completed ? 'completed' : ''}`}>
                                        {step.text}
                                    </span>
                                </div>
                            ))}
                        </div>
                    )}

                    {/* Separator */}
                    <div className="todo-separator"></div>
                </>
            )}
        </div>
    );
}
