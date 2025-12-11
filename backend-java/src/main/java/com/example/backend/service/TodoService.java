package com.example.backend.service;
import com.example.backend.config.APIResponse;
import com.example.backend.dtos.TodoRequestDTO;
import com.example.backend.dtos.TodoStepRequestDTO;
import com.example.backend.dtos.TodoStepUpdateDTO;
import com.example.backend.dtos.TodoUpdateDTO;
import com.example.backend.model.Todo;
import com.example.backend.model.TodoStep;
import com.example.backend.repository.TodoRepository;
import com.example.backend.repository.TodoStepRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class TodoService {
    private final TodoRepository todoRepository;
    private final TodoStepRepository todoStepRepository;

    public TodoService(TodoRepository todoRepository, TodoStepRepository todoStepRepository) {
        this.todoRepository = todoRepository;
        this.todoStepRepository = todoStepRepository;
    }


    public List<Todo> getAllTodos() {
        return todoRepository.findAll();
    }

    public Todo createTodo(TodoRequestDTO request) {
        // Validate title (defensive check)
        if (request.getTitle() == null || request.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Todo title must not be empty");
        }

        Todo todo = new Todo();
        todo.setTitle(request.getTitle());
        todo.setCompleted(Boolean.TRUE.equals(request.getCompleted()));

        if (request.getSteps() != null) {
            for (TodoStepRequestDTO stepDTO : request.getSteps()) {
                // Validate step items
                if (stepDTO.getItems() == null || stepDTO.getItems().trim().isEmpty()) {
                    throw new IllegalArgumentException("Step items must not be empty");
                }

                TodoStep step = new TodoStep();
                step.setItems(stepDTO.getItems());
                step.setCompleted(Boolean.TRUE.equals(stepDTO.getCompleted()));
                step.setTodo(todo);
                todo.getSteps().add(step);
            }
        }
        return todoRepository.save(todo);
    }

    public Optional<Todo> addStep(Long todoId, TodoStepRequestDTO request) {

        if (request.getItems() == null || request.getItems().trim().isEmpty()) {
            throw new IllegalArgumentException("Step items must not be empty");
        }

        return todoRepository.findById(todoId)
                .map(todo -> {
                    TodoStep step = new TodoStep();
                    step.setItems(request.getItems());
                    step.setCompleted(Boolean.TRUE.equals(request.getCompleted()));
                    step.setTodo(todo);
                    todo.getSteps().add(step);
                    Todo saved = todoRepository.save(todo);
                    return saved;
                });
    }


    public Optional<Todo> updateTodo(Long id, TodoUpdateDTO updateDTO) {
        Optional<Todo> optionalTodo = todoRepository.findById(id);
        
        if (optionalTodo.isEmpty()) {
            return Optional.empty();
        }
        
        Todo todo = optionalTodo.get();
        
        // Cập nhật title nếu có
        if (updateDTO.getTitle() != null && !updateDTO.getTitle().isBlank()) {
            todo.setTitle(updateDTO.getTitle());
        }
        
        // Cập nhật completed nếu có
        if (updateDTO.getCompleted() != null) {
            todo.setCompleted(updateDTO.getCompleted());
            
            // Nếu completed = true → đánh dấu tất cả step con cũng hoàn thành
            if (updateDTO.getCompleted()) {
                for (TodoStep step : todo.getSteps()) {
                    step.setCompleted(true);
                }
            }
        }
        
        // Lưu todo (cascade sẽ tự động lưu các step con)
        Todo savedTodo = todoRepository.save(todo);
        return Optional.of(savedTodo);
    }

    public boolean deleteTodo(Long id) {
        Optional<Todo> optionalTodo = todoRepository.findById(id);
        if (optionalTodo.isEmpty()) {
            return false;
        }
        todoRepository.delete(optionalTodo.get());
        return true;
    }

    public Optional<TodoStep> updateStep(Long id, TodoStepUpdateDTO updateDTO) {
        Optional<TodoStep> optionalStep = todoStepRepository.findById(id);

        if (optionalStep.isEmpty()) {
            return Optional.empty();
        }

        TodoStep step = optionalStep.get();
        // Cập nhật nội dung nếu có
        if (updateDTO.getItems() != null) {
            if (updateDTO.getItems().trim().isEmpty()) {
                throw new IllegalArgumentException("Step items must not be empty");
            }
            step.setItems(updateDTO.getItems());
        }

        // Cập nhật trạng thái nếu có
        if (updateDTO.getCompleted() != null) {
            step.setCompleted(updateDTO.getCompleted());
        }

        // Đồng bộ trạng thái Todo cha nếu cần
        Todo parent = step.getTodo();
        if (parent != null) {
            boolean allCompleted = parent.getSteps()
                    .stream()
                    .allMatch(TodoStep::isCompleted);
            parent.setCompleted(allCompleted);
            todoRepository.save(parent);
        }

        TodoStep savedStep = todoStepRepository.save(step);
        return Optional.of(savedStep);
    }

    public boolean deleteStep(Long id) {
        Optional<TodoStep> optionalStep = todoStepRepository.findById(id);
        if (optionalStep.isEmpty()) {
            return false;
        }

        TodoStep step = optionalStep.get();
        Todo parent = step.getTodo();

        // Giữ đồng bộ collection trong bộ nhớ
        if (parent != null) {
            parent.getSteps().remove(step);
        }

        todoStepRepository.delete(step);

        if (parent != null) {
            boolean allCompleted = parent.getSteps().isEmpty() || parent.getSteps().stream().allMatch(TodoStep::isCompleted);
            parent.setCompleted(allCompleted);
            todoRepository.save(parent);
        }

        return true;
    }

}