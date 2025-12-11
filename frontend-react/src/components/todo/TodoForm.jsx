import { useState } from 'react';

export default function TodoForm({ onAdd }) {
    const [text, setText] = useState('');
    const [stepInputs, setStepInputs] = useState([]);
    const [errors, setErrors] = useState({});
    const [isSubmitting, setIsSubmitting] = useState(false);

    const validateForm = () => {
        const newErrors = {};

        // Validate title
        if (!text.trim()) {
            newErrors.title = 'Tên công việc không được để trống';
        } else if (text.trim().length < 3) {
            newErrors.title = 'Tên công việc phải có ít nhất 3 ký tự';
        } else if (text.trim().length > 200) {
            newErrors.title = 'Tên công việc không được quá 200 ký tự';
        }

        // Validate steps
        stepInputs.forEach((step, index) => {
            if (step.trim() && step.trim().length < 2) {
                newErrors[`step_${index}`] = 'Bước thực hiện phải có ít nhất 2 ký tự';
            }
            if (step.trim() && step.trim().length > 150) {
                newErrors[`step_${index}`] = 'Bước thực hiện không được quá 150 ký tự';
            }
        });

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        
        if (!validateForm()) {
            return;
        }

        setIsSubmitting(true);
        setErrors({});

        try {
            const validSteps = stepInputs.filter(s => s.trim());
            await onAdd(text.trim(), validSteps);
            
            // Reset form on success
            setText('');
            setStepInputs([]);
            setErrors({});
        } catch (error) {
            setErrors({ 
                submit: error.message || 'Có lỗi xảy ra khi thêm công việc. Vui lòng thử lại!' 
            });
        } finally {
            setIsSubmitting(false);
        }
    };

    const updateStepInput = (index, value) => {
        const newSteps = [...stepInputs];
        newSteps[index] = value;
        setStepInputs(newSteps);
        
        // Clear error for this step
        if (errors[`step_${index}`]) {
            const newErrors = { ...errors };
            delete newErrors[`step_${index}`];
            setErrors(newErrors);
        }
    };

    const addStepInput = () => {
        setStepInputs([...stepInputs, '']);
    };

    const removeStepInput = (index) => {
        const newSteps = stepInputs.filter((_, i) => i !== index);
        setStepInputs(newSteps);
        
        // Clear error for this step
        const newErrors = { ...errors };
        delete newErrors[`step_${index}`];
        setErrors(newErrors);
    };

    const handleStepKeyDown = (e, index) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            addStepInput();
        }
    };

    const handleTextChange = (value) => {
        setText(value);
        // Clear title error when user types
        if (errors.title) {
            const newErrors = { ...errors };
            delete newErrors.title;
            setErrors(newErrors);
        }
    };

    return (
        <form className="space-y-4" onSubmit={handleSubmit}>
            {/* General error message */}
            {errors.submit && (
                <div className="p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
                    {errors.submit}
                </div>
            )}

            <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                    Tên công việc <span className="text-red-500">*</span>
                </label>
                <input
                    type="text"
                    className={`input ${errors.title ? 'border-red-300 focus:ring-red-500' : ''}`}
                    placeholder="Nhập tên công việc..."
                    value={text}
                    onChange={(e) => handleTextChange(e.target.value)}
                    aria-label="Add a task"
                    disabled={isSubmitting}
                />
                {errors.title && (
                    <p className="mt-1 text-sm text-red-600">{errors.title}</p>
                )}
            </div>

            {stepInputs.length > 0 && (
                <div className="space-y-2">
                    <label className="block text-sm font-medium text-gray-700">
                        Các bước thực hiện
                    </label>
                    {stepInputs.map((step, index) => (
                        <div key={index}>
                            <div className="flex gap-2 items-center">
                                <span className="text-gray-400 text-sm w-6">{index + 1}.</span>
                                <input
                                    type="text"
                                    className={`input flex-1 text-sm ${errors[`step_${index}`] ? 'border-red-300 focus:ring-red-500' : ''}`}
                                    placeholder="Bước tiếp theo..."
                                    value={step}
                                    onChange={(e) => updateStepInput(index, e.target.value)}
                                    onKeyDown={(e) => handleStepKeyDown(e, index)}
                                    disabled={isSubmitting}
                                />
                                <button
                                    type="button"
                                    className="text-gray-400 hover:text-red-600 transition-colors p-1 disabled:opacity-50"
                                    onClick={() => removeStepInput(index)}
                                    aria-label="Remove step"
                                    disabled={isSubmitting}
                                >
                                    <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                                        <path d="M4 4l8 8m0-8l-8 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
                                    </svg>
                                </button>
                            </div>
                            {errors[`step_${index}`] && (
                                <p className="mt-1 ml-8 text-sm text-red-600">{errors[`step_${index}`]}</p>
                            )}
                        </div>
                    ))}
                </div>
            )}

            <button
                type="button"
                className="text-sm text-blue-600 hover:text-blue-700 font-medium flex items-center gap-1 disabled:opacity-50 disabled:cursor-not-allowed"
                onClick={addStepInput}
                disabled={isSubmitting}
            >
                <span>+</span> Thêm bước thực hiện
            </button>

            <button 
                type="submit" 
                className="btn btn-primary w-full py-3"
                disabled={!text.trim() || isSubmitting}
            >
                {isSubmitting ? 'Đang thêm...' : 'Thêm công việc'}
            </button>
        </form>
    );
}
