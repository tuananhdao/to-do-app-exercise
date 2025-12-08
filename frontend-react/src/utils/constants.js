// App constants and configuration

export const APP_NAME = 'Todo App';
export const APP_VERSION = '1.0.0';

// Todo status
export const TODO_STATUS = {
  ALL: 'all',
  ACTIVE: 'active',
  COMPLETED: 'completed',
};

// Local storage keys
export const STORAGE_KEYS = {
  TODOS: 'todos',
  THEME: 'theme',
};

// API endpoints (when backend is ready)
export const API_ENDPOINTS = {
  TODOS: '/todos',
  TODO_BY_ID: (id) => `/todos/${id}`,
};
