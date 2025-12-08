import api from './api';

// Todo service functions for API calls
// Currently using localStorage, but these can be activated when backend is ready

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

  // Update a todo
  update: async (id, todoData) => {
    try {
      return await api.put(`/todos/${id}`, todoData);
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
};

export default todoService;
