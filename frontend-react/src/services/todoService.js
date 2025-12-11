import api from './api';

// Todo service functions for API calls
const todoService = {
  // Get all todos
  getAll: async () => {
    try {
      return await api.get('/todos');
    } catch (error) {
      console.error('Error fetching todos:', error);
      throw error;
    }
  },

  // Get a single todo
  getById: async (id) => {
    try {
      return await api.get(`/todos/${id}`);
    } catch (error) {
      console.error('Error fetching todo:', error);
      throw error;
    }
  },

  // Create a new todo
  create: async (todoData) => {
    try {
      return await api.post('/todos', todoData);
    } catch (error) {
      console.error('Error creating todo:', error);
      throw error;
    }
  },

  // Update a todo (use PATCH as per backend)
  update: async (id, todoData) => {
    try {
      return await api.patch(`/todos/${id}`, todoData);
    } catch (error) {
      console.error('Error updating todo:', error);
      throw error;
    }
  },

  // Delete a todo
  delete: async (id) => {
    try {
      return await api.delete(`/todos/${id}`);
    } catch (error) {
      console.error('Error deleting todo:', error);
      throw error;
    }
  },

  // Update a step (use PATCH as per backend)
  updateStep: async (stepId, stepData) => {
    try {
      return await api.patch(`/todos/items/${stepId}`, stepData);
    } catch (error) {
      console.error('Error updating step:', error);
      throw error;
    }
  },

  // Delete a step
  deleteStep: async (stepId) => {
    try {
      return await api.delete(`/todos/items/${stepId}`);
    } catch (error) {
      console.error('Error deleting step:', error);
      throw error;
    }
  },
};

export default todoService;
