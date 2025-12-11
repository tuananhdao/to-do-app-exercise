import { useState } from 'react';
import './TodoForm.css';

export default function TodoForm({ onAdd }) {
    const [text, setText] = useState('');
    const [stepInputs, setStepInputs] = useState([]);

    const handleSubmit = (e) => {
        e.preventDefault();
        if (text.trim()) {
            const validSteps = stepInputs.filter(s => s.trim());
            // Pass title (not text) and validSteps (array of strings)
            onAdd(text.trim(), validSteps);
            setText('');
            setStepInputs([]);
        }
    };

    const updateStepInput = (index, value) => {
        const newSteps = [...stepInputs];
        newSteps[index] = value;
        setStepInputs(newSteps);
    };

    const addStepInput = () => {
        setStepInputs([...stepInputs, '']);
    };

    const removeStepInput = (index) => {
        const newSteps = stepInputs.filter((_, i) => i !== index);
        setStepInputs(newSteps);
    };

    const handleStepKeyDown = (e, index) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            addStepInput();
        }
    };

    return (
        <form className="todo-form" onSubmit={handleSubmit}>
            <div className="form-main">
                <input
                    type="text"
                    className="todo-input"
                    placeholder="+ Add a task"
                    value={text}
                    onChange={(e) => setText(e.target.value)}
                    onKeyDown={(e) => {
                        if (e.key === 'Enter') {
                            handleSubmit(e);
                        }
                    }} aria-label="Add a task"

                />
            </div>

            {stepInputs.map((step, index) => (
                <div key={index} className="step-input-row">
                    <span className="step-number">{index + 1}</span>
                    <input
                        type="text"
                        className="step-input"
                        placeholder="Next step"
                        value={step}
                        onChange={(e) => updateStepInput(index, e.target.value)}
                        onKeyDown={(e) => handleStepKeyDown(e, index)}
                    />
                    <button
                        type="button"
                        className="btn-remove-step"
                        onClick={() => removeStepInput(index)}
                    >
                    </button>
                </div>
            ))}

            <div className="add-step-inline" onClick={addStepInput}>
                + Add step
            </div>
        </form>
    );
}
