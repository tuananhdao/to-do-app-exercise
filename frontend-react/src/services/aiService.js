import api from './api';

/**
 * AI Service for voice transcription and task generation
 */
const aiService = {
  /**
   * Transcribe audio to text using AI
   * @param {string} audioBase64 - Base64 encoded audio data
   * @param {string} audioFormat - Audio format (e.g., 'webm', 'wav', 'mp3')
   * @returns {Promise<{text: string}>} Transcribed text
   */
  voiceToText: async (audioBase64, audioFormat = 'webm') => {
    try {
      const response = await api.post('/voice-to-text', {
        audioBase64,
        audioFormat,
      });
      return response;
    } catch (error) {
      console.error('Voice to text error:', error);
      throw new Error(error.message || 'Không thể chuyển đổi giọng nói thành văn bản');
    }
  },

  /**
   * Generate tasks from prompt using AI
   * @param {string} prompt - User prompt describing tasks
   * @param {number} maxTasks - Maximum number of tasks to generate (default: 5)
   * @returns {Promise<{tasks: Array}>} Generated tasks
   */
  generateTasks: async (prompt, maxTasks = 5) => {
    try {
      const response = await api.post('/generate-tasks', {
        prompt,
        maxTasks,
      });
      return response;
    } catch (error) {
      console.error('Generate tasks error:', error);
      throw new Error(error.message || 'Không thể tạo danh sách công việc');
    }
  },
};

export default aiService;
