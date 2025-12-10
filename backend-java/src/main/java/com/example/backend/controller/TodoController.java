package com.example.backend.controller;

import com.example.backend.config.APIResponse;
import com.example.backend.dtos.TodoRequestDTO;
import com.example.backend.dtos.TodoStepRequestDTO;
import com.example.backend.dtos.TodoStepUpdateDTO;
import com.example.backend.dtos.TodoUpdateDTO;
import com.example.backend.model.Todo;
import com.example.backend.service.TodoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;


@RestController
@RequestMapping("/api/v1/todos")
@RequiredArgsConstructor
public class TodoController {

    private final TodoService todoService;

    @GetMapping
    public ResponseEntity<APIResponse<List<Todo>>> getAllTodos(){
        List<Todo> todos = todoService.getAllTodos();
        return ResponseEntity.ok(APIResponse.success(todos));
    }
    @PostMapping
    public ResponseEntity<APIResponse<Todo>> createTodo(@RequestBody TodoRequestDTO request) {

        // Validate title
        if (request.getTitle() == null || request.getTitle().isBlank()) {
            return ResponseEntity
                    .badRequest()
                    .body(APIResponse.error("Title must not be empty"));
        }

        // Validate steps if provided
        if (request.getSteps() != null) {
            for (TodoStepRequestDTO step : request.getSteps()) {
                if (step.getItems() == null || step.getItems().isBlank()) {
                    return ResponseEntity
                            .badRequest()
                            .body(APIResponse.error("Step items must not be empty"));
                }
            }
        }

        try {
            Todo saved = todoService.createTodo(request);
            return ResponseEntity.ok(APIResponse.success(saved));
        } catch (IllegalArgumentException e) {
            return ResponseEntity
                    .badRequest()
                    .body(APIResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity
                    .internalServerError()
                    .body(APIResponse.error("Failed to create todo: " + e.getMessage()));
        }
    }

    @PatchMapping("/{id}")
    public ResponseEntity<APIResponse<Todo>> updateTodo(
            @PathVariable Long id,
            @RequestBody TodoUpdateDTO updateDTO) {
        
        Optional<Todo> updatedTodo = todoService.updateTodo(id, updateDTO);
        
        if (updatedTodo.isEmpty()) {
            return ResponseEntity
                    .status(404)
                    .body(APIResponse.notFound("Todo not found with id: " + id));
        }
        
        return ResponseEntity.ok(APIResponse.success(updatedTodo.get()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<APIResponse<String>> deleteTodo(@PathVariable Long id) {
        boolean deleted = todoService.deleteTodo(id);
        if (!deleted) {
            return ResponseEntity
                    .status(404)
                    .body(APIResponse.notFound("Cannot delete non-existing todo"));
        }
        return ResponseEntity.ok(APIResponse.success("Deleted successfully"));
    }

    @PatchMapping("/items/{id}")
    public ResponseEntity<APIResponse<?>> updateStep(
            @PathVariable Long id,
            @RequestBody TodoStepUpdateDTO updateDTO) {

        if (updateDTO.getItems() != null && updateDTO.getItems().isBlank()) {
            return ResponseEntity
                    .badRequest()
                    .body(APIResponse.error("Step items must not be empty"));
        }

        try {
            var updated = todoService.updateStep(id, updateDTO);
            if (updated.isEmpty()) {
                return ResponseEntity
                        .status(404)
                        .body(APIResponse.notFound("TodoStep not found with id: " + id));
            }
            return ResponseEntity.ok(APIResponse.success(updated.get()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity
                    .badRequest()
                    .body(APIResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity
                    .internalServerError()
                    .body(APIResponse.error("Failed to update step: " + e.getMessage()));
        }
    }

    @DeleteMapping("/items/{id}")
    public ResponseEntity<APIResponse<String>> deleteStep(@PathVariable Long id) {
        boolean deleted = todoService.deleteStep(id);
        if (!deleted) {
            return ResponseEntity
                    .status(404)
                    .body(APIResponse.notFound("Cannot delete non-existing step"));
        }
        return ResponseEntity.ok(APIResponse.success("Step deleted successfully"));
    }
    
}
