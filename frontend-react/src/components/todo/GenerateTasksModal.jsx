import { useState, useEffect } from 'react';
import aiService from '../../services/aiService';

export default function GenerateTasksModal({ isOpen, onClose, onTaskGenerated, initialPrompt = '' }) {
  const [prompt, setPrompt] = useState(initialPrompt);
  const [isGenerating, setIsGenerating] = useState(false);
  const [error, setError] = useState(null);
  const [generatedTask, setGeneratedTask] = useState(null);

  // Update prompt when initialPrompt changes
  useEffect(() => {
    if (isOpen && initialPrompt) {
      setPrompt(initialPrompt);
    }
  }, [isOpen, initialPrompt]);

  const handleGenerate = async () => {
    if (!prompt.trim()) {
      setError('Vui lòng nhập mô tả công việc');
      return;
    }

    setIsGenerating(true);
    setError(null);
    setGeneratedTask(null);

    try {
      // Backend tự động lưu task vào DB và trả về task đã lưu
      const savedTask = await aiService.generateTasks(prompt);
      
      if (savedTask && savedTask.id) {
        setGeneratedTask(savedTask);
        // Notify parent that task was created (to refresh list)
        onTaskGenerated();
        
        // Auto close modal after 1.5 seconds to show success message
        setTimeout(() => {
          handleClose();
        }, 1500);
      } else {
        setError('Không thể tạo công việc. Vui lòng thử lại!');
      }
    } catch (err) {
      setError(err.message || 'Có lỗi xảy ra khi tạo công việc');
    } finally {
      setIsGenerating(false);
    }
  };

  const handleClose = () => {
    setPrompt('');
    setGeneratedTask(null);
    setError(null);
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-xl font-bold text-gray-900">Tạo công việc bằng AI</h3>
          <button
            onClick={handleClose}
            className="text-gray-400 hover:text-gray-600"
            disabled={isGenerating}
          >
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M18 6L6 18M6 6l12 12" />
            </svg>
          </button>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
            {error}
          </div>
        )}

        {/* Input Section */}
        {!generatedTask && (
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Mô tả công việc <span className="text-red-500">*</span>
              </label>
              <textarea
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                rows="4"
                placeholder="Ví dụ: Tạo danh sách đi chợ nấu món cá kho"
                value={prompt}
                onChange={(e) => setPrompt(e.target.value)}
                disabled={isGenerating}
              />
              <p className="mt-2 text-xs text-gray-500">
                💡 AI sẽ tạo 1 công việc với các bước chi tiết và tự động lưu vào danh sách
              </p>
            </div>

            <button
              onClick={handleGenerate}
              disabled={isGenerating || !prompt.trim()}
              className="w-full btn btn-primary py-3 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isGenerating ? (
                <span className="flex items-center justify-center gap-2">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                  Đang tạo và lưu...
                </span>
              ) : (
                '✨ Tạo công việc'
              )}
            </button>
          </div>
        )}

        {/* Success Section */}
        {generatedTask && (
          <div className="space-y-4">
            <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
              <div className="flex items-center gap-2 text-green-700 mb-2">
                <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                </svg>
                <span className="font-medium">Đã tạo và lưu thành công!</span>
              </div>
            </div>

            <div className="border rounded-lg p-4 bg-gray-50">
              <h4 className="font-bold text-gray-900 text-lg mb-3">{generatedTask.title}</h4>
              {generatedTask.steps && generatedTask.steps.length > 0 && (
                <div>
                  <p className="text-sm text-gray-600 mb-2 font-medium">Các bước thực hiện:</p>
                  <ul className="space-y-2">
                    {generatedTask.steps.map((step, index) => (
                      <li key={step.id} className="text-sm text-gray-700 flex items-start gap-2">
                        <span className="text-blue-600 font-medium min-w-[24px]">{index + 1}.</span>
                        <span>{step.items}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </div>

            <button
              onClick={handleClose}
              className="w-full btn btn-primary py-3"
            >
              Đóng
            </button>
          </div>
        )}

        {!generatedTask && (
          <div className="mt-4 text-center text-sm text-gray-500">
            <p>💡 Mẹo: Mô tả chi tiết để AI tạo công việc chính xác hơn</p>
          </div>
        )}
      </div>
    </div>
  );
}
