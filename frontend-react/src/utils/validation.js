/**
 * Validation utilities for todo application
 */

/**
 * Validates todo title
 * @param {string} title - The todo title to validate
 * @returns {string|null} Error message or null if valid
 */
export const validateTodoTitle = (title) => {
  if (!title || !title.trim()) {
    return 'Title cannot be empty';
  }
  if (title.trim().length < 3) {
    return 'Title must be at least 3 characters';
  }
  if (title.length > 200) {
    return 'Title cannot exceed 200 characters';
  }
  return null; // no error
};

/**
 * Validates step item
 * @param {string} item - The step item to validate
 * @returns {string|null} Error message or null if valid
 */
export const validateStepItem = (item) => {
  if (!item || !item.trim()) {
    return 'Step cannot be empty';
  }
  if (item.trim().length < 2) {
    return 'Step must be at least 2 characters';
  }
  if (item.length > 100) {
    return 'Step cannot exceed 100 characters';
  }
  return null;
};
