import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import React from 'react';
import TodoForm from '../components/todo/TodoForm';
import TodoItem from '../components/todo/TodoItem';

describe('Frontend Tests', () => {
  describe('TodoForm Component', () => {
    let mockOnAdd;

    beforeEach(() => {
      mockOnAdd = vi.fn().mockResolvedValue();
    });

    it('should render the form', () => {
      render(<TodoForm onAdd={mockOnAdd} />);
      
      expect(screen.getByPlaceholderText('Nhập tên công việc...')).toBeInTheDocument();
      expect(screen.getByText(/Thêm công việc/i)).toBeInTheDocument();
    });

    it('should disable submit button when input is empty', () => {
      render(<TodoForm onAdd={mockOnAdd} />);
      
      const submitButton = screen.getByRole('button', { name: /Thêm công việc/i });
      expect(submitButton).toBeDisabled();
    });

    it('should enable submit button when input has text', async () => {
      const user = userEvent.setup();
      render(<TodoForm onAdd={mockOnAdd} />);
      
      const input = screen.getByPlaceholderText('Nhập tên công việc...');
      await user.type(input, 'New Todo');
      
      const submitButton = screen.getByRole('button', { name: /Thêm công việc/i });
      expect(submitButton).not.toBeDisabled();
    });

    it('should show validation error for short title', async () => {
      const user = userEvent.setup();
      render(<TodoForm onAdd={mockOnAdd} />);
      
      const input = screen.getByPlaceholderText('Nhập tên công việc...');
      await user.type(input, 'AB');
      
      const submitButton = screen.getByRole('button', { name: /Thêm công việc/i });
      await user.click(submitButton);
      
      await waitFor(() => {
        expect(screen.getByText(/phải có ít nhất 3 ký tự/i)).toBeInTheDocument();
      });
    });

    it('should submit form with valid data', async () => {
      const user = userEvent.setup();
      render(<TodoForm onAdd={mockOnAdd} />);
      
      const input = screen.getByPlaceholderText('Nhập tên công việc...');
      await user.type(input, 'New Todo Task');
      
      const submitButton = screen.getByRole('button', { name: /Thêm công việc/i });
      await user.click(submitButton);
      
      await waitFor(() => {
        expect(mockOnAdd).toHaveBeenCalledWith('New Todo Task', []);
      });
    });

    it('should add and submit with steps', async () => {
      const user = userEvent.setup();
      render(<TodoForm onAdd={mockOnAdd} />);
      
      const input = screen.getByPlaceholderText('Nhập tên công việc...');
      await user.type(input, 'New Todo');
      
      const addStepButton = screen.getByText(/Thêm bước thực hiện/i);
      await user.click(addStepButton);
      
      const stepInput = screen.getByPlaceholderText('Bước tiếp theo...');
      await user.type(stepInput, 'Step 1');
      
      const submitButton = screen.getByRole('button', { name: /Thêm công việc/i });
      await user.click(submitButton);
      
      await waitFor(() => {
        expect(mockOnAdd).toHaveBeenCalledWith('New Todo', expect.arrayContaining(['Step 1']));
      });
    });

    it('should reset form after successful submission', async () => {
      const user = userEvent.setup();
      render(<TodoForm onAdd={mockOnAdd} />);
      
      const input = screen.getByPlaceholderText('Nhập tên công việc...');
      await user.type(input, 'New Todo');
      
      const submitButton = screen.getByRole('button', { name: /Thêm công việc/i });
      await user.click(submitButton);
      
      await waitFor(() => {
        expect(input).toHaveValue('');
      });
    });
  });

  describe('TodoItem Component', () => {
    const mockTodo = {
      id: 1,
      title: 'Test Todo',
      completed: false,
      steps: [
        { id: 101, items: 'Step 1', completed: false },
        { id: 102, items: 'Step 2', completed: true },
      ],
    };

    const mockHandlers = {
      onToggle: vi.fn(),
      onDelete: vi.fn(),
      onUpdate: vi.fn(),
      onUpdateStep: vi.fn(),
      onToggleStep: vi.fn(),
      onAddItem: vi.fn(),
      onDeleteStep: vi.fn(),
    };

    beforeEach(() => {
      vi.clearAllMocks();
    });

    it('should render todo with title and steps', () => {
      render(<TodoItem todo={mockTodo} {...mockHandlers} />);
      
      expect(screen.getByText('Test Todo')).toBeInTheDocument();
      expect(screen.getByText('Step 1')).toBeInTheDocument();
      expect(screen.getByText('Step 2')).toBeInTheDocument();
    });

    it('should render collapse button', () => {
      render(<TodoItem todo={mockTodo} {...mockHandlers} />);
      
      const collapseButton = screen.getByTitle(/Thu gọn/i);
      expect(collapseButton).toBeInTheDocument();
    });

    it('should show checkbox for todo', () => {
      render(<TodoItem todo={mockTodo} {...mockHandlers} />);
      
      const checkboxes = screen.getAllByRole('checkbox');
      expect(checkboxes.length).toBeGreaterThan(0);
    });

    it('should toggle todo completion', async () => {
      const user = userEvent.setup();
      render(<TodoItem todo={mockTodo} {...mockHandlers} />);
      
      const checkboxes = screen.getAllByRole('checkbox');
      const todoCheckbox = checkboxes[0];
      await user.click(todoCheckbox);
      
      expect(mockHandlers.onToggle).toHaveBeenCalledWith(mockTodo.id);
    });

    it('should disable inputs when todo is completed', () => {
      const completedTodo = { ...mockTodo, completed: true };
      render(<TodoItem todo={completedTodo} {...mockHandlers} />);
      
      const checkboxes = screen.getAllByRole('checkbox');
      checkboxes.forEach(checkbox => {
        expect(checkbox).toBeDisabled();
      });
    });

    it('should not show add step input when completed', () => {
      const completedTodo = { ...mockTodo, completed: true };
      render(<TodoItem todo={completedTodo} {...mockHandlers} />);
      
      expect(screen.queryByPlaceholderText(/Thêm bước/i)).not.toBeInTheDocument();
    });

    it('should add new step on Enter key', async () => {
      const user = userEvent.setup();
      render(<TodoItem todo={mockTodo} {...mockHandlers} />);
      
      const addStepInput = screen.getByPlaceholderText(/Thêm bước/i);
      await user.type(addStepInput, 'New Step{Enter}');
      
      expect(mockHandlers.onAddItem).toHaveBeenCalledWith(mockTodo.id, 'New Step');
    });

    it('should apply strikethrough to completed todo', () => {
      const completedTodo = { ...mockTodo, completed: true };
      render(<TodoItem todo={completedTodo} {...mockHandlers} />);
      
      const titleElement = screen.getByText('Test Todo');
      expect(titleElement).toHaveClass('line-through');
    });

    it('should apply strikethrough to completed step', () => {
      render(<TodoItem todo={mockTodo} {...mockHandlers} />);
      
      const completedStep = screen.getByText('Step 2');
      expect(completedStep).toHaveClass('line-through');
    });

    it('should have delete button', () => {
      render(<TodoItem todo={mockTodo} {...mockHandlers} />);
      
      const deleteButton = screen.getByTitle(/Xóa$/i);
      expect(deleteButton).toBeInTheDocument();
    });

    it('should call onDelete when delete button clicked', async () => {
      const user = userEvent.setup();
      render(<TodoItem todo={mockTodo} {...mockHandlers} />);
      
      const deleteButton = screen.getByTitle(/Xóa$/i);
      await user.click(deleteButton);
      
      expect(mockHandlers.onDelete).toHaveBeenCalledWith(mockTodo.id);
    });
  });

  describe('Basic Functionality Tests', () => {
    it('should pass basic math test', () => {
      expect(1 + 1).toBe(2);
      expect(5 * 3).toBe(15);
    });

    it('should handle string operations', () => {
      const str = '  test  ';
      expect(str.trim()).toBe('test');
      expect(str.length).toBe(8);
    });

    it('should handle array operations', () => {
      const arr = [1, 2, 3];
      expect(arr.filter(x => x > 1)).toEqual([2, 3]);
      expect(arr.map(x => x * 2)).toEqual([2, 4, 6]);
    });
  });
});
