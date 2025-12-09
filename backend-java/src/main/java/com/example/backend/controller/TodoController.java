package com.example.backend.controller;

import com.example.backend.config.APIResponse;
import com.example.backend.dtos.TodoRequestDTO;
import com.example.backend.model.Todo;
import com.example.backend.service.TodoService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/v1/todos")
public class TodoController {

    public final TodoService todoService;

    public TodoController(TodoService todoService) {
        this.todoService = todoService;
    }

    @GetMapping
    public ResponseEntity<APIResponse<List<Todo>>> getAllTodos(){
        List<Todo> todos = todoService.getAllTodos();
        return ResponseEntity.ok(APIResponse.success(todos));
    }
    @PostMapping
    public ResponseEntity<APIResponse<Todo>> createTodo(@RequestBody TodoRequestDTO request) {


        if (request.getTitle() == null || request.getTitle().isBlank()) {
            return ResponseEntity
                    .badRequest()
                    .body(APIResponse.error("Title must not be empty"));
        }

        Todo saved = todoService.createTodo(request);
        return ResponseEntity.ok(APIResponse.success(saved));
    }





    
}
