import { useState, useRef, useEffect } from 'react';
import './TodoItem.css';

export default function TodoItem({ todo, onToggle, onToggleStep, onDelete, onUpdate, deleteStep }) {
    const [isStepsExpanded, setIsStepsExpanded] = useState(true);
    const [editingTitle, setEditingTitle] = useState(!todo.title?.trim());
    const [editingStepId, setEditingStepId] = useState(null);
    const [titleValue, setTitleValue] = useState(todo.title || '');
    const [stepValues, setStepValues] = useState(
        todo.steps ? Object.fromEntries(todo.steps.map(s => [s.id, s.items])) : {}
    );
    const [newStepValue, setNewStepValue] = useState('');
    const titleInputRef = useRef(null);
    const stepInputRef = useRef(null);
    const newStepInputRef = useRef(null);

    useEffect(() => {
        setTitleValue(todo.title || '');
        setStepValues(todo.steps ? Object.fromEntries(todo.steps.map(s => [s.id, s.items])) : {});
        setEditingTitle(!todo.title?.trim());
    }, [todo]);

    useEffect(() => {
        if (editingTitle && titleInputRef.current) {
            titleInputRef.current.focus();
            titleInputRef.current.select();
        }
    }, [editingTitle]);

    useEffect(() => {
        if (editingStepId && stepInputRef.current) {
            stepInputRef.current.focus();
            stepInputRef.current.select();
        }
    }, [editingStepId]);

    const handleTitleBlur = () => {
        if (titleValue.trim() && titleValue !== todo.title) {
            const steps = todo.steps ? todo.steps.map(s => s.items) : [];
            onUpdate(todo.id, titleValue.trim(), steps);
            setEditingTitle(false);
        } else if (titleValue.trim()) {
            // No change, just exit edit mode
            setEditingTitle(false);
        } else {
            // Keep placeholder active but don't lose focus abruptly
            setTitleValue('');
            setEditingTitle(true);
        }
    };

    const handleTitleKeyDown = (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            handleTitleBlur();
        } else if (e.key === 'Escape') {
            setTitleValue(todo.title);
            setEditingTitle(false);
        }
    };

    const handleStepBlur = (stepId) => {
        const newValue = stepValues[stepId]?.trim();
        if (newValue && newValue !== todo.steps.find(s => s.id === stepId)?.items) {
            const updatedSteps = todo.steps.map(s =>
                s.id === stepId ? newValue : s.items
            );
            onUpdate(todo.id, todo.title, updatedSteps);
        } else {
            setStepValues(prev => ({
                ...prev,
                [stepId]: todo.steps.find(s => s.id === stepId)?.items || ''
            }));
        }
        setEditingStepId(null);
    };

    const handleStepKeyDown = (e, stepId) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            handleStepBlur(stepId);
        } else if (e.key === 'Escape') {
            setStepValues(prev => ({
                ...prev,
                [stepId]: todo.steps.find(s => s.id === stepId)?.items || ''
            }));
            setEditingStepId(null);
        }
    };

    const handleNewStepKeyDown = (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            if (newStepValue.trim()) {
                const currentSteps = todo.steps ? todo.steps.map(s => s.items) : [];
                onUpdate(todo.id, todo.title, [...currentSteps, newStepValue.trim()]);
                setNewStepValue('');
            }
        } else if (e.key === 'Escape') {
            setNewStepValue('');
            if (newStepInputRef.current) {
                newStepInputRef.current.blur();
            }
        }
    };

    const handleNewStepBlur = () => {
        if (newStepValue.trim()) {
            const currentSteps = todo.steps ? todo.steps.map(s => s.items) : [];
            onUpdate(todo.id, todo.title, [...currentSteps, newStepValue.trim()]);
            setNewStepValue('');
        } else {
            setNewStepValue('');
        }
    };

    const handleDeleteStep = (stepId) => {
        deleteStep(stepId);
    };

    const hasSteps = todo.steps && todo.steps.length > 0;

    return (
        <div className={`todo-item ${todo.completed ? 'completed' : ''}`}>
            <div className="todo-header">
                <input
                    type="checkbox"
                    className="todo-checkbox"
                    checked={todo.completed}
                    onChange={() => onToggle(todo.id)}
                />
                {editingTitle ? (
                    <input
                        ref={titleInputRef}
                        type="text"
                        className="todo-text-input"
                        value={titleValue}
                        onChange={(e) => setTitleValue(e.target.value)}
                        onBlur={handleTitleBlur}
                        onKeyDown={handleTitleKeyDown}
                        placeholder="+ Add a task"
                    />
                ) : (
                    <span
                        className={`todo-text ${!todo.title?.trim() ? 'todo-text-placeholder' : ''}`}
                        onClick={() => !todo.completed && setEditingTitle(true)}
                        style={{ cursor: todo.completed ? 'default' : 'text' }}
                    >
                        {todo.title || '+ Add a task'}
                    </span>
                )}

                <div className="todo-actions-right">
                    <button
                        onClick={() => onDelete(todo.id)}
                        className="btn-delete"
                        title="Delete"
                    >
                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                            <path d="M3 4h10M5 4V3a1 1 0 011-1h4a1 1 0 011 1v1m1 0v9a1 1 0 01-1 1H5a1 1 0 01-1-1V4h8z" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                        </svg>
                    </button>

                    {(hasSteps || newStepValue) && (
                        <button
                            className="btn-expand"
                            onClick={() => setIsStepsExpanded(!isStepsExpanded)}
                            title={isStepsExpanded ? "Collapse steps" : "Expand steps"}
                        >
                            <svg width="12" height="12" viewBox="0 0 12 12" fill="currentColor">
                                <path d={isStepsExpanded ? "M2 4l4 4 4-4" : "M4 2l4 4-4 4"} stroke="currentColor" strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round" />
                            </svg>
                        </button>
                    )}
                </div>
            </div>

            {isStepsExpanded && (
                <div className="todo-steps">
                    {hasSteps && todo.steps.map(step => (
                        <div key={step.id} className="step-item">
                            <input
                                type="checkbox"
                                className="step-checkbox"
                                checked={step.completed}
                                onChange={() => onToggleStep(todo.id, step.id)}
                            />
                            {editingStepId === step.id ? (
                                <input
                                    ref={stepInputRef}
                                    type="text"
                                    className="step-text-input"
                                    value={stepValues[step.id] || ''}
                                    onChange={(e) => setStepValues(prev => ({ ...prev, [step.id]: e.target.value }))}
                                    onBlur={() => handleStepBlur(step.id)}
                                    onKeyDown={(e) => handleStepKeyDown(e, step.id)}
                                />
                            ) : (
                                <span
                                    className={`step-text ${step.completed ? 'completed' : ''}`}
                                    onClick={() => !step.completed && setEditingStepId(step.id)}
                                    style={{ cursor: step.completed ? 'default' : 'text' }}
                                >
                                    {step.items}
                                </span>
                            )}
                            <button
                                className="btn-delete-step"
                                onClick={() => handleDeleteStep(step.id)}
                                title="Delete step"
                            >
                                <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                                    <path d="M3.5 3.5l7 7m0-7l-7 7" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                                </svg>
                            </button>
                        </div>
                    ))}

                    <div className="step-item add-step">
                        <span className="step-placeholder-icon">+</span>
                        <input
                            ref={newStepInputRef}
                            type="text"
                            className="step-text-input placeholder-input"
                            placeholder="Add step"
                            value={newStepValue}
                            onChange={(e) => setNewStepValue(e.target.value)}
                            onKeyDown={handleNewStepKeyDown}
                            onBlur={handleNewStepBlur}
                        />
                    </div>
                </div>
            )}
        </div>
    );
}
