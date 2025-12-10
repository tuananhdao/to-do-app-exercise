import { useState, useEffect } from 'react';
import useLocalStorage from './useLocalStorage';

export default function useTodos() {
  const [todos, setTodos] = useLocalStorage('todos', []);

  // Add todo with optional steps
  const addTodo = (text, steps = []) => {
    const newTodo = {
      id: Date.now(),
      text,
      completed: false,
      steps: steps.map((stepText, index) => ({
        id: Date.now() + index + 1,
        text: stepText,
        completed: false,
      })),
      createdAt: new Date().toISOString(),
    };
    setTodos([...todos, newTodo]);
  };

  // Toggle todo - updates all steps if exists
  const toggleTodo = (id) => {
    setTodos(
      todos.map(todo => {
        if (todo.id === id) {
          const newCompleted = !todo.completed;
          // If todo has steps, update all of them
          if (todo.steps && todo.steps.length > 0) {
            return {
              ...todo,
              completed: newCompleted,
              steps: todo.steps.map(step => ({ ...step, completed: newCompleted })),
            };
          }
          // If no steps, just toggle todo
          return { ...todo, completed: newCompleted };
        }
        return todo;
      })
    );
  };

  // Toggle individual step - auto-updates parent
  const toggleStep = (todoId, stepId) => {
    setTodos(
      todos.map(todo => {
        if (todo.id === todoId) {
          const updatedSteps = todo.steps.map(step =>
            step.id === stepId ? { ...step, completed: !step.completed } : step
          );
          // Auto-complete parent if all steps done
          const allStepsCompleted = updatedSteps.every(step => step.completed);
          return {
            ...todo,
            steps: updatedSteps,
            completed: allStepsCompleted,
          };
        }
        return todo;
      })
    );
  };

  const deleteTodo = (id) => {
    setTodos(todos.filter(todo => todo.id !== id));
  };

  // Update todo text and steps
  const updateTodo = (id, newText, newSteps = []) => {
    setTodos(
      todos.map(todo => {
        if (todo.id === id) {
          const updatedSteps = newSteps.map((stepText, index) => {
            const existingStep = todo.steps && todo.steps[index];
            return existingStep
              ? { ...existingStep, text: stepText }
              : {
                  id: Date.now() + index,
                  text: stepText,
                  completed: false,
                };
          });
          
          // Recalculate completion if has steps
          const allStepsCompleted = updatedSteps.length > 0 
            ? updatedSteps.every(step => step.completed)
            : todo.completed;
          
          return {
            ...todo,
            text: newText,
            steps: updatedSteps,
            completed: allStepsCompleted,
          };
        }
        return todo;
      })
    );
  };

  return {
    todos,
    addTodo,
    toggleTodo,
    toggleStep,
    deleteTodo,
    updateTodo,
  };
}
