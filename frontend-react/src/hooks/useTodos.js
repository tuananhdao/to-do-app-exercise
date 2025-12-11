import { useState, useEffect } from 'react';
import todoService from '../services/todoService';

export default function useTodos() {
  const [todos, setTodos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [toastMessage, setToastMessage] = useState(null);
  const [toastType, setToastType] = useState('error');

  // Fetch todos on mount
  useEffect(() => {
    fetchTodos();
  }, []);

  const showToast = (message, type = 'error') => {
    setToastMessage(message);
    setToastType(type);
  };

  const clearToast = () => {
    setToastMessage(null);
  };

  const parseError = (err) => {
    // Network error
    if (!err.message || err.message === 'Failed to fetch') {
      return 'Network error. Please check your connection.';
    }
    // Backend error message (already parsed in api.js)
    return err.message;
  };

  const fetchTodos = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await todoService.getAll();
      setTodos(data);
    } catch (err) {
      const errorMessage = parseError(err);
      setError(errorMessage);
      showToast(errorMessage, 'error');
      console.error('Failed to fetch todos:', err);
    } finally {
      setLoading(false);
    }
  };

  // Add todo with optional steps
  const addTodo = async (title, stepItems = []) => {
    try {
      setError(null);
      const todoData = {
        title,
        completed: false,
        steps: stepItems.map(items => ({
          items,
          completed: false,
        })),
      };
      const newTodo = await todoService.create(todoData);
      setTodos([...todos, newTodo]);
      showToast('Todo created successfully', 'success');
    } catch (err) {
      const errorMessage = parseError(err);
      setError(errorMessage);
      showToast(errorMessage, 'error');
      console.error('Failed to add todo:', err);
      throw err;
    }
  };

  // Toggle todo - updates all steps if exists
  const toggleTodo = async (id) => {
    try {
      setError(null);
      const todo = todos.find(t => t.id === id);
      if (!todo) return;
      const newCompleted = !todo.completed;
      const updatedTodo = await todoService.update(id, { completed: newCompleted });
      
      setTodos(todos.map(t => t.id === id ? updatedTodo : t));
    } catch (err) {
      const errorMessage = parseError(err);
      setError(errorMessage);
      showToast(errorMessage, 'error');
      console.error('Failed to toggle todo:', err);
      throw err;
    }
  };

  // Toggle individual step - auto-updates parent
  const toggleStep = async (todoId, stepId) => {
    try {
      setError(null);
      const todo = todos.find(t => t.id === todoId);
      if (!todo) return;

      const step = todo.steps.find(s => s.id === stepId);
      if (!step) return;

      const newCompleted = !step.completed;
      // API expects 'text' in request, but returns 'items' in response
      await todoService.updateStep(stepId, {
        text: step.items,
        completed: newCompleted,
      });

      // Refresh todo list to get updated state from backend
      await fetchTodos();
    } catch (err) {
      const errorMessage = parseError(err);
      setError(errorMessage);
      showToast(errorMessage, 'error');
      console.error('Failed to toggle step:', err);
      throw err;
    }
  };

  const deleteTodo = async (id) => {
    try {
      setError(null);
      await todoService.delete(id);
      setTodos(todos.filter(todo => todo.id !== id));
      showToast('Todo deleted successfully', 'success');
    } catch (err) {
      const errorMessage = parseError(err);
      setError(errorMessage);
      showToast(errorMessage, 'error');
      console.error('Failed to delete todo:', err);
      throw err;
    }
  };

  // Update todo title and steps
  const updateTodo = async (id, newTitle, newStepItems = []) => {
    try {
      setError(null);
      const updatedTodo = await todoService.update(id, {
        title: newTitle,
      });
      
      setTodos(todos.map(t => t.id === id ? updatedTodo : t));
      showToast('Todo updated successfully', 'success');
    } catch (err) {
      const errorMessage = parseError(err);
      setError(errorMessage);
      showToast(errorMessage, 'error');
      console.error('Failed to update todo:', err);
      throw err;
    }
  };

  const deleteStep = async (id) => {
    try {
      setError(null);
      await todoService.deleteStep(id);
      const data = await todoService.getAll();
      setTodos(data);
      showToast('Step deleted successfully', 'success');
    } catch (err) {
      const errorMessage = parseError(err);
      setError(errorMessage);
      showToast(errorMessage, 'error');
      console.error('Failed to delete step:', err);
      throw err;
    }
  };

  return {
    todos,
    loading,
    error,
    toastMessage,
    toastType,
    addTodo,
    toggleTodo,
    toggleStep,
    deleteTodo,
    updateTodo,
    refreshTodos: fetchTodos,
    clearToast,
    deleteStep,
  };
}
