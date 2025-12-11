import { useState } from 'react';
import { validateTodoTitle, validateStepItem } from '../../utils/validation';
import ErrorMessage from '../common/ErrorMessage';
import './TodoForm.css';

export default function TodoForm({ onAdd }) {
    const [text, setText] = useState('');
    const [stepInputs, setStepInputs] = useState([]);
    const [errors, setErrors] = useState({
        title: '',
        steps: []
    });
    const [touched, setTouched] = useState({
        title: false,
        steps: []
    });

    const validateTitle = (value) => {
        const error = validateTodoTitle(value);
        setErrors(prev => ({ ...prev, title: error || '' }));
        return !error;
    };

    const validateStep = (index, value) => {
        const error = validateStepItem(value);
        setErrors(prev => {
            const newStepErrors = [...prev.steps];
            newStepErrors[index] = error || '';
            return { ...prev, steps: newStepErrors };
        });
        return !error;
    };

    const handleTitleBlur = () => {
        setTouched(prev => ({ ...prev, title: true }));
        validateTitle(text);
    };

    const handleStepBlur = (index) => {
        setTouched(prev => {
            const newTouchedSteps = [...prev.steps];
            newTouchedSteps[index] = true;
            return { ...prev, steps: newTouchedSteps };
        });
        validateStep(index, stepInputs[index]);
    };

    const handleSubmit = (e) => {
        e.preventDefault();

        // Mark all fields as touched
        setTouched({
            title: true,
            steps: stepInputs.map(() => true)
        });

        // Validate all fields
        const titleValid = validateTitle(text);
        const stepsValid = stepInputs.every((step, index) => {
            if (!step.trim()) return true; // Allow empty steps (they'll be filtered)
            return validateStep(index, step);
        });

        if (!titleValid || !stepsValid) {
            return; // Don't submit if there are errors
        }

        if (text.trim()) {
            const validSteps = stepInputs.filter(s => s.trim());
            onAdd(text.trim(), validSteps);
            // Clear form and errors
            setText('');
            setStepInputs([]);
            setErrors({ title: '', steps: [] });
            setTouched({ title: false, steps: [] });
        }
    };

    const updateStepInput = (index, value) => {
        const newSteps = [...stepInputs];
        newSteps[index] = value;
        setStepInputs(newSteps);

        // Validate if touched
        if (touched.steps[index]) {
            validateStep(index, value);
        }
    };

    const addStepInput = () => {
        setStepInputs([...stepInputs, '']);
        setErrors(prev => ({ ...prev, steps: [...prev.steps, ''] }));
        setTouched(prev => ({ ...prev, steps: [...prev.steps, false] }));
    };

    const removeStepInput = (index) => {
        const newSteps = stepInputs.filter((_, i) => i !== index);
        setStepInputs(newSteps);

        const newErrors = errors.steps.filter((_, i) => i !== index);
        setErrors(prev => ({ ...prev, steps: newErrors }));

        const newTouched = touched.steps.filter((_, i) => i !== index);
        setTouched(prev => ({ ...prev, steps: newTouched }));
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
                    className={`todo-input ${touched.title && errors.title ? 'input-error' : ''}`}
                    placeholder="+ Add a task"
                    value={text}
                    onChange={(e) => setText(e.target.value)}
                    onBlur={handleTitleBlur}
                    onKeyDown={(e) => {
                        if (e.key === 'Enter') {
                            handleSubmit(e);
                        }
                    }}
                    aria-label="Add a task"
                />
                {touched.title && errors.title && <ErrorMessage message={errors.title} />}
            </div>

            {stepInputs.map((step, index) => (
                <div key={index} className="step-input-container">
                    <div className="step-input-row">
                        <span className="step-number">{index + 1}</span>
                        <input
                            type="text"
                            className={`step-input ${touched.steps[index] && errors.steps[index] ? 'input-error' : ''}`}
                            placeholder="Next step"
                            value={step}
                            onChange={(e) => updateStepInput(index, e.target.value)}
                            onBlur={() => handleStepBlur(index)}
                            onKeyDown={(e) => handleStepKeyDown(e, index)}
                        />
                        <button
                            type="button"
                            className="btn-remove-step"
                            onClick={() => removeStepInput(index)}
                        >
                        </button>
                    </div>
                    {touched.steps[index] && errors.steps[index] && (
                        <ErrorMessage message={errors.steps[index]} />
                    )}
                </div>
            ))}

            <div className="add-step-inline" onClick={addStepInput}>
                + Add step
            </div>
        </form>
    );
}
