import { useState } from 'react';
import TodoList from '../components/todo/TodoList';
import TodoForm from '../components/todo/TodoForm';
import VoiceInputModal from '../components/todo/VoiceInputModal';
import GenerateTasksModal from '../components/todo/GenerateTasksModal';
import useTodos from '../hooks/useTodos';

export default function TodoPage() {
    const { todos, loading, error, addTodo, toggleTodo, toggleStep, updateStep, deleteTodo, updateTodo, addItemToTodo, deleteStepFromTodo, fetchTodos } = useTodos();
    
    const [isVoiceModalOpen, setIsVoiceModalOpen] = useState(false);
    const [isGenerateModalOpen, setIsGenerateModalOpen] = useState(false);
    const [voicePrompt, setVoicePrompt] = useState('');

    const handleVoiceInput = () => {
        setIsVoiceModalOpen(true);
    };

    const handleVoiceTextGenerated = (text) => {
        setVoicePrompt(text);
        setIsGenerateModalOpen(true);
    };

    const handleTaskGenerated = async () => {
        // Backend đã tự động lưu task vào DB rồi
        // Chỉ cần refresh lại danh sách todos
        await fetchTodos();
    };

    if (loading) {
        return (
            <div className="min-h-screen bg-gray-50 flex items-center justify-center">
                <div className="text-gray-600">Đang tải...</div>
            </div>
        );
    }

    return (
        <div className="h-full bg-gray-50">
            {/* Voice Input Modal */}
            <VoiceInputModal
                isOpen={isVoiceModalOpen}
                onClose={() => setIsVoiceModalOpen(false)}
                onTextGenerated={handleVoiceTextGenerated}
            />

            {/* Generate Tasks Modal */}
            <GenerateTasksModal
                isOpen={isGenerateModalOpen}
                onClose={() => {
                    setIsGenerateModalOpen(false);
                    setVoicePrompt('');
                }}
                onTaskGenerated={handleTaskGenerated}
                initialPrompt={voicePrompt}
            />

            <div className="h-full flex">
                {/* Left side - Add Todo Form (30%) */}
                <div className="w-[33%] bg-white border-r border-gray-200 p-6 overflow-y-auto flex items-start justify-center">
                    <div className="w-full max-w-md pt-8">
                        <h2 className="text-2xl font-bold text-gray-900 mb-2">Thêm công việc mới</h2>
                        <p className="text-sm text-gray-500 mb-4">Nhập thủ công hoặc sử dụng giọng nói</p>
                        
                        {/* Voice Input Button */}
                        <button
                            onClick={handleVoiceInput}
                            className="w-full mb-6 p-4 border-2 border-dashed border-gray-300 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors group"
                        >
                            <div className="flex items-center justify-center gap-3">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-gray-400 group-hover:text-blue-600">
                                    <path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/>
                                    <path d="M19 10v2a7 7 0 0 1-14 0v-2"/>
                                    <line x1="12" y1="19" x2="12" y2="23"/>
                                    <line x1="8" y1="23" x2="16" y2="23"/>
                                </svg>
                                <span className="text-gray-600 group-hover:text-blue-600 font-medium">Nhập bằng giọng nói</span>
                            </div>
                        </button>

                        <div className="text-center text-sm text-gray-400 mb-4">
                            hoặc
                        </div>

                        <TodoForm onAdd={addTodo} />
                    </div>
                </div>

                {/* Right side - Todo List (65%) */}
                <div className="w-[65%] p-6 overflow-y-auto">
                    <div className="max-w-4xl">
                        <div className="mb-6">
                            <h1 className="text-3xl font-bold text-gray-900">Danh sách công việc</h1>
                            <p className="text-gray-600 mt-1">Quản lý và theo dõi tiến độ</p>
                        </div>

                        {error && (
                            <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg text-red-700">
                                Lỗi: {error}
                            </div>
                        )}

                        <TodoList
                            todos={todos}
                            onToggle={toggleTodo}
                            onToggleStep={toggleStep}
                            onUpdateStep={updateStep}
                            onDelete={deleteTodo}
                            onUpdate={updateTodo}
                            onAddItem={addItemToTodo}
                            onDeleteStep={deleteStepFromTodo}
                        />
                    </div>
                </div>
            </div>
        </div>
    );
}
