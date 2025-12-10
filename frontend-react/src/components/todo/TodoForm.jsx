import { useState } from 'react';
import './TodoForm.css';

export default function TodoForm({ onAdd }) {
    const [text, setText] = useState('');
    const [stepInputs, setStepInputs] = useState([]);
    const [showSteps, setShowSteps] = useState(false);

    const handleSubmit = (e) => {
        e.preventDefault();
        if (text.trim()) {
            const validSteps = stepInputs.filter(s => s.trim());
            onAdd(text.trim(), validSteps);
            setText('');
            setStepInputs([]);
            setShowSteps(false);
        }
    };

    const updateStepInput = (index, value) => {
        const newSteps = [...stepInputs];
        newSteps[index] = value;
        setStepInputs(newSteps);
    };

    const addStepInput = () => {
        setStepInputs([...stepInputs, '']);
        setShowSteps(true);
    };

    const removeStepInput = (index) => {
        const newSteps = stepInputs.filter((_, i) => i !== index);
        setStepInputs(newSteps);
        if (newSteps.length === 0) {
            setShowSteps(false);
        }
    };

    return (
        <form className="todo-form" onSubmit={handleSubmit}>
            <div className="form-main">
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
            </div>

            {showSteps && (
                <div className="steps-section">
                    {stepInputs.map((step, index) => (
                        <div key={index} className="step-input-row">
                            <span className="step-number">{index + 1}.</span>
                            <input
                                type="text"
                                className="step-input"
                                placeholder={`Step ${index + 1}`}
                                value={step}
                                onChange={(e) => updateStepInput(index, e.target.value)}
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
                </div>
            )}

            {!showSteps && (
                <button
                    type="button"
                    className="btn-add-step"
                    onClick={addStepInput}
                >
                    Add Steps (optional)
                </button>
            )}

            {showSteps && (
                <button
                    type="button"
                    className="btn-add-more-step"
                    onClick={addStepInput}
                >
                    Add Another Step
                </button>
            )}
        </form>
    );
}
