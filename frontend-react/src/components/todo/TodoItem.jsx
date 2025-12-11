import { useState, useRef, useEffect } from 'react';

export default function TodoItem({ todo, onToggle, onToggleStep, onUpdateStep, onDelete, onUpdate, onAddItem, onDeleteStep }) {
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
            setEditingTitle(false);
        } else {
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
        const originalValue = todo.steps.find(s => s.id === stepId)?.items;
        
        if (newValue && newValue !== originalValue) {
            // Use the new updateStep function
            if (onUpdateStep) {
                onUpdateStep(stepId, newValue);
            }
        } else {
            // Revert to original value if empty or unchanged
            setStepValues(prev => ({
                ...prev,
                [stepId]: originalValue || ''
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
                if (onAddItem) {
                    onAddItem(todo.id, newStepValue.trim());
                } else {
                    const currentSteps = todo.steps ? todo.steps.map(s => s.items) : [];
                    onUpdate(todo.id, todo.title, [...currentSteps, newStepValue.trim()]);
                }
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
            if (onAddItem) {
                onAddItem(todo.id, newStepValue.trim());
            } else {
                const currentSteps = todo.steps ? todo.steps.map(s => s.items) : [];
                onUpdate(todo.id, todo.title, [...currentSteps, newStepValue.trim()]);
            }
            setNewStepValue('');
        } else {
            setNewStepValue('');
        }
    };

    const handleDeleteStep = (stepId) => {
        if (onDeleteStep) {
            onDeleteStep(stepId);
        } else {
            const updatedSteps = todo.steps.filter(s => s.id !== stepId).map(s => s.items);
            onUpdate(todo.id, todo.title, updatedSteps);
        }
    };

    const hasSteps = todo.steps && todo.steps.length > 0;

    return (
        <div className={`card p-4 ${todo.completed ? 'bg-gray-50' : 'bg-white'} transition-all`}>
            {/* Header */}
            <div className="flex items-start gap-3">
                <input
                    type="checkbox"
                    className="checkbox mt-0.5 flex-shrink-0"
                    checked={todo.completed}
                    onChange={() => onToggle(todo.id)}
                    disabled={todo.completed}
                />
                
                <div className="flex-1 min-w-0">
                    {editingTitle ? (
                        <input
                            ref={titleInputRef}
                            type="text"
                            className="input w-full"
                            value={titleValue}
                            onChange={(e) => setTitleValue(e.target.value)}
                            onBlur={handleTitleBlur}
                            onKeyDown={handleTitleKeyDown}
                            placeholder="Nhập tên công việc..."
                            disabled={todo.completed}
                        />
                    ) : (
                        <div
                            className={`text-base px-2 py-1 rounded ${
                                todo.completed ? 'line-through text-gray-500 cursor-default' : 'text-gray-900 cursor-text hover:bg-gray-50'
                            } ${!todo.title?.trim() ? 'text-gray-400' : ''}`}
                            onClick={() => !todo.completed && setEditingTitle(true)}
                        >
                            {todo.title || 'Nhập tên công việc...'}
                        </div>
                    )}
                </div>

                <div className="flex items-center gap-1 flex-shrink-0">
                    <button
                        className="p-1.5 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded transition-colors"
                        onClick={() => setIsStepsExpanded(!isStepsExpanded)}
                        title={isStepsExpanded ? "Thu gọn" : "Mở rộng"}
                    >
                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none" className={`transition-transform ${isStepsExpanded ? '' : '-rotate-90'}`}>
                            <path d="M4 6l4 4 4-4" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                        </svg>
                    </button>
                    <button
                        onClick={() => onDelete(todo.id)}
                        className="p-1.5 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded transition-colors"
                        title="Xóa"
                    >
                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                            <path d="M3 4h10M5 4V3a1 1 0 011-1h4a1 1 0 011 1v1m1 0v9a1 1 0 01-1 1H5a1 1 0 01-1-1V4h8z" 
                                stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
                        </svg>
                    </button>
                </div>
            </div>

            {/* Steps */}
            {isStepsExpanded && (
                <div className="mt-3 ml-8 space-y-1.5">
                    {hasSteps && todo.steps.map(step => (
                        <div key={step.id} className="flex items-start gap-2 group">
                            <input
                                type="checkbox"
                                className="checkbox mt-0.5 flex-shrink-0"
                                checked={step.completed}
                                onChange={() => onToggleStep(todo.id, step.id)}
                                disabled={todo.completed}
                            />
                            {editingStepId === step.id ? (
                                <input
                                    ref={stepInputRef}
                                    type="text"
                                    className="input flex-1 text-sm"
                                    value={stepValues[step.id] || ''}
                                    onChange={(e) => setStepValues(prev => ({ ...prev, [step.id]: e.target.value }))}
                                    onBlur={() => handleStepBlur(step.id)}
                                    onKeyDown={(e) => handleStepKeyDown(e, step.id)}
                                    disabled={todo.completed}
                                />
                            ) : (
                                <div
                                    className={`flex-1 text-sm px-2 py-1 rounded ${
                                        step.completed || todo.completed 
                                            ? 'line-through text-gray-400 cursor-default' 
                                            : 'text-gray-700 cursor-text hover:bg-gray-50'
                                    }`}
                                    onClick={() => !step.completed && !todo.completed && setEditingStepId(step.id)}
                                >
                                    {step.items}
                                </div>
                            )}
                            <button
                                className={`p-1 text-gray-400 transition-all flex-shrink-0 ${
                                    todo.completed 
                                        ? 'opacity-30 cursor-not-allowed' 
                                        : 'opacity-0 group-hover:opacity-100 hover:text-red-600'
                                }`}
                                onClick={() => !todo.completed && handleDeleteStep(step.id)}
                                title="Xóa bước"
                                disabled={todo.completed}
                            >
                                <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                                    <path d="M3.5 3.5l7 7m0-7l-7 7" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
                                </svg>
                            </button>
                        </div>
                    ))}

                    {/* Add new step - only show if todo is not completed */}
                    {!todo.completed && (
                        <div className="flex items-center gap-2">
                            <span className="text-gray-400 text-lg leading-none flex-shrink-0 ml-1">+</span>
                            <input
                                ref={newStepInputRef}
                                type="text"
                                className="input flex-1 text-sm border-dashed"
                                placeholder="Thêm bước..."
                                value={newStepValue}
                                onChange={(e) => setNewStepValue(e.target.value)}
                                onKeyDown={handleNewStepKeyDown}
                                onBlur={handleNewStepBlur}
                            />
                        </div>
                    )}
                </div>
            )}
        </div>
    );
}
