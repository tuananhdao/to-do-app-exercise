package com.example.backend.service;
import com.example.backend.config.APIResponse;
import com.example.backend.dtos.TodoRequestDTO;
import com.example.backend.dtos.TodoStepRequestDTO;
import com.example.backend.model.Todo;
import com.example.backend.model.TodoStep;
import com.example.backend.repository.TodoRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TodoService {
    private final TodoRepository todoRepository;

    public TodoService(TodoRepository todoRepository) {
        this.todoRepository = todoRepository;
    }


    public List<Todo> getAllTodos() {
        return todoRepository.findAll();
    }

    public Todo createTodo(TodoRequestDTO request) {
        Todo todo = new Todo();
        todo.setTitle(request.getTitle());
        todo.setCompleted(Boolean.TRUE.equals(request.getCompleted()));

        if (request.getSteps() != null) {
            for (TodoStepRequestDTO stepDTO : request.getSteps()) {
                TodoStep step = new TodoStep();
                step.setItems(stepDTO.getItems());
                step.setCompleted(Boolean.TRUE.equals(stepDTO.getCompleted()));
                step.setTodo(todo);
                todo.getSteps().add(step);
            }
        }
        return todoRepository.save(todo);
    }



}