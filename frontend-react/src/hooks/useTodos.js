import { useState, useEffect } from 'react';
import todoService from '../services/todoService';

export default function useTodos() {
  const [todos, setTodos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Fetch todos on mount
  useEffect(() => {
    fetchTodos();
  }, []);

  const fetchTodos = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await todoService.getAll();
      setTodos(data);
    } catch (err) {
      setError(err.message);
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
    } catch (err) {
      setError(err.message);
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
      setError(err.message);
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
      setError(err.message);
      console.error('Failed to toggle step:', err);
      throw err;
    }
  };

  const deleteTodo = async (id) => {
    try {
      setError(null);
      await todoService.delete(id);
      setTodos(todos.filter(todo => todo.id !== id));
    } catch (err) {
      setError(err.message);
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
    } catch (err) {
      setError(err.message);
      console.error('Failed to update todo:', err);
      throw err;
    }
  };

  return {
    todos,
    loading,
    error,
    addTodo,
    toggleTodo,
    toggleStep,
    deleteTodo,
    updateTodo,
    refreshTodos: fetchTodos,
  };
}
