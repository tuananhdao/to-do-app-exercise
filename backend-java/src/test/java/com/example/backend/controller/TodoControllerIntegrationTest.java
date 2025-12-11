package com.example.backend.controller;

import com.example.backend.model.Todo;
import com.example.backend.repository.TodoRepository;
import jakarta.transaction.Transactional;
import com.example.backend.model.TodoStep;
import com.example.backend.repository.TodoRepository;
import com.example.backend.repository.TodoStepRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;

import java.util.List;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class TodoControllerIntegrationTest {
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private TodoRepository todoRepository;

    @BeforeEach
    void cleanDatabase() {
        todoRepository.deleteAll();
    }

    @Test
    @DisplayName("DB khong co Todo nao va tra ve danh sach rong")
    void test_getAllTodos_shouldReturn200_withEmptyList() throws Exception {
        // Arrange: DB đã rỗng nhờ @BeforeEach

        // Act + Assert
        mockMvc.perform(get("/api/v1/todos"))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(1000))
                .andExpect(jsonPath("$.message").value("Success"))
                .andExpect(jsonPath("$.result").isArray())
                .andExpect(jsonPath("$.result.length()").value(0));
    }

    @Test
    @DisplayName("DB co san 2 Todo tra ve size=2")
    void test_getAllTodos_shouldReturn200_withTodosList() throws Exception {
        // Arrange
        Todo todo1 = new Todo();
        todo1.setTitle("Todo 1");
        todo1.setCompleted(false);

        Todo todo2 = new Todo();
        todo2.setTitle("Todo 2");
        todo2.setCompleted(true);

        todoRepository.save(todo1);
        todoRepository.save(todo2);

        // Act + Assert
        mockMvc.perform(get("/api/v1/todos"))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(1000))
                .andExpect(jsonPath("$.message").value("Success"))
                .andExpect(jsonPath("$.result").isArray())
                .andExpect(jsonPath("$.result.length()").value(2))
                .andExpect(jsonPath("$.result[0].title").value("Todo 1"))
                .andExpect(jsonPath("$.result[1].title").value("Todo 2"));
    }

    @Test
    @DisplayName("Post Todo voi du lieu hop le, khong co steps")
    void test_createTodo_shouldReturn200_withValidData() throws Exception {
        // Arrange
        String requestJson = """
                {
                  "title": "Buy milk",
                  "completed": false
                }
                """;

        // Act + Assert response
        mockMvc.perform(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestJson))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(1000))
                .andExpect(jsonPath("$.message").value("Success"))
                .andExpect(jsonPath("$.result.id").isNumber())
                .andExpect(jsonPath("$.result.title").value("Buy milk"))
                .andExpect(jsonPath("$.result.completed").value(false));

        // Assert DB
        List<Todo> todos = todoRepository.findAll();
        assertEquals(1, todos.size());
        assertEquals("Buy milk", todos.get(0).getTitle());
        assertFalse(todos.get(0).isCompleted());
    }

    @Transactional
    @Test
    @DisplayName("Post Todo voi title va steps hop le")
    void test_createTodo_shouldReturn200_withSteps() throws Exception {
        // Arrange
        String requestJson = """
                {
                  "title": "Todo with steps",
                  "completed": false,
                  "steps": [
                    { "items": "Step 1", "completed": false },
                    { "items": "Step 2", "completed": true }
                  ]
                }
                """;
        // Act + Assert
        mockMvc.perform(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestJson))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(1000))
                .andExpect(jsonPath("$.message").value("Success"))
                .andExpect(jsonPath("$.result.id").isNumber())
                .andExpect(jsonPath("$.result.title").value("Todo with steps"))
                .andExpect(jsonPath("$.result.steps").isArray())
                .andExpect(jsonPath("$.result.steps.length()").value(2))
                .andExpect(jsonPath("$.result.steps[0].items").value("Step 1"))
                .andExpect(jsonPath("$.result.steps[1].items").value("Step 2"));

        // DB: 1 todo, 2 steps (cascade)
        List<Todo> todos = todoRepository.findAll();
        assertEquals(1, todos.size());
        assertEquals(2, todos.get(0).getSteps().size());

    }
    @Test
    @DisplayName("Post body khong co title")
    void test_createTodo_shouldReturn400_whenTitleIsNull() throws Exception {
        // Arrange
        String requestJson = """
                {
                  "completed": false
                }
                """;

        // Act + Assert
        mockMvc.perform(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestJson))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(9999))
                .andExpect(jsonPath("$.message").value("Title must not be empty"));
    }

    @Test
    @DisplayName("Post Todo voi title la space")
    void test_createTodo_shouldReturn400_whenTitleIsBlank() throws Exception {
        // Arrange
        String requestJson = """
                {
                  "title": " "
                }
                """;

        // Act + Assert
        mockMvc.perform(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestJson))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(9999))
                .andExpect(jsonPath("$.message").value("Title must not be empty"));
    }

    @Test
    @DisplayName("Post Todo voi step co items rong")
    void test_createTodo_shouldReturn400_whenStepItemsIsBlank() throws Exception {
        // Arrange
        String requestJson = """
                {
                  "title": "Todo with invalid step",
                  "completed": false,
                  "steps": [
                    { "items": "", "completed": false }
                  ]
                }
                """;

        // Act + Assert
        mockMvc.perform(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestJson))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(9999))
                .andExpect(jsonPath("$.message").value("Step items must not be empty"));
    }



import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Integration tests cho TodoController
 * - Sử dụng H2 (profile "test")
 * - Dùng MockMvc để gọi trực tiếp REST API
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
@DisplayName("TodoController Integration Tests")
class TodoControllerIntegrationTest {

    private MockMvc mockMvc;

    @Autowired
    private WebApplicationContext webApplicationContext;

    @Autowired
    private TodoRepository todoRepository;

    @Autowired
    private TodoStepRepository todoStepRepository;

    @BeforeEach
    void cleanDatabase() {
        todoStepRepository.deleteAll();
        todoRepository.deleteAll();
        // Build MockMvc manually since AutoConfigureMockMvc is not available in Spring Boot 4
        this.mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
    }

    // =========================
    // PATCH /api/v1/todos/{id}
    // =========================

    @Test
    @DisplayName("PATCH /todos/{id} - update title -> 200")
    void test_updateTodo_shouldReturn200_whenUpdateTitle() throws Exception {
        Todo todo = createTodo("Old Title", false);

        mockMvc.perform(patch("/api/v1/todos/{id}", todo.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"title\":\"Updated Title\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.result.title").value("Updated Title"));
    }

    @Test
    @DisplayName("PATCH /todos/{id} - update completed -> 200")
    void test_updateTodo_shouldReturn200_whenUpdateCompleted() throws Exception {
        Todo todo = createTodo("Todo", false);

        mockMvc.perform(patch("/api/v1/todos/{id}", todo.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"completed\":true}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.result.completed").value(true));
    }

    @Test
    @DisplayName("PATCH /todos/{id} - not found -> 404")
    void test_updateTodo_shouldReturn404_whenTodoNotFound() throws Exception {
        mockMvc.perform(patch("/api/v1/todos/{id}", 999)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"title\":\"Updated\"}"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Todo not found with id: 999"));
    }

    // =========================
    // DELETE /api/v1/todos/{id}
    // =========================

    @Test
    @DisplayName("DELETE /todos/{id} - exists -> 200")
    void test_deleteTodo_shouldReturn200_whenTodoExists() throws Exception {
        Todo todo = createTodo("To delete", false);

        mockMvc.perform(delete("/api/v1/todos/{id}", todo.getId()))
                .andExpect(status().isOk())
            .andExpect(jsonPath("$.result").value("Deleted successfully"));

        assertThat(todoRepository.findById(todo.getId())).isEmpty();
    }

    @Test
    @DisplayName("DELETE /todos/{id} - not found -> 404")
    void test_deleteTodo_shouldReturn404_whenTodoNotFound() throws Exception {
        mockMvc.perform(delete("/api/v1/todos/{id}", 999))
                .andExpect(status().isNotFound());
    }

    // =========================
    // PATCH /api/v1/todos/items/{id}
    // =========================

    @Test
    @DisplayName("PATCH /items/{id} - update items -> 200")
    void test_updateStep_shouldReturn200_whenUpdateItems() throws Exception {
        TodoStep step = createTodoWithSingleStep("Todo", "Old items", false);

        mockMvc.perform(patch("/api/v1/todos/items/{id}", step.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                .content("{\"text\":\"Updated items\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.result.items").value("Updated items"));
    }

    @Test
    @DisplayName("PATCH /items/{id} - update completed -> 200")
    void test_updateStep_shouldReturn200_whenUpdateCompleted() throws Exception {
        TodoStep step = createTodoWithSingleStep("Todo", "Work", false);

        mockMvc.perform(patch("/api/v1/todos/items/{id}", step.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"completed\":true}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.result.completed").value(true));
    }

    @Test
    @DisplayName("PATCH /items/{id} - blank items -> 400")
    void test_updateStep_shouldReturn400_whenItemsIsBlank() throws Exception {
        TodoStep step = createTodoWithSingleStep("Todo", "Work", false);

        mockMvc.perform(patch("/api/v1/todos/items/{id}", step.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                .content("{\"text\":\" \"}"))
            .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("PATCH /items/{id} - not found -> 404")
    void test_updateStep_shouldReturn404_whenStepNotFound() throws Exception {
        mockMvc.perform(patch("/api/v1/todos/items/{id}", 999)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"items\":\"Updated\"}"))
                .andExpect(status().isNotFound());
    }

    // =========================
    // DELETE /api/v1/todos/items/{id}
    // =========================

    @Test
    @DisplayName("DELETE /items/{id} - exists -> 200")
    void test_deleteStep_shouldReturn200_whenStepExists() throws Exception {
        TodoStep step = createTodoWithSingleStep("Todo", "Step", false);

        mockMvc.perform(delete("/api/v1/todos/items/{id}", step.getId()))
                .andExpect(status().isOk())
            .andExpect(jsonPath("$.result").value("Step deleted successfully"));

        assertThat(todoStepRepository.findById(step.getId())).isEmpty();
    }

    @Test
    @DisplayName("DELETE /items/{id} - not found -> 404")
    void test_deleteStep_shouldReturn404_whenStepNotFound() throws Exception {
        mockMvc.perform(delete("/api/v1/todos/items/{id}", 999))
                .andExpect(status().isNotFound());
    }

    // ================
    // Helper functions
    // ================

    private Todo createTodo(String title, boolean completed) {
        Todo todo = new Todo();
        todo.setTitle(title);
        todo.setCompleted(completed);
        return todoRepository.save(todo);
    }

    private TodoStep createTodoWithSingleStep(String title, String items, boolean completed) {
        Todo todo = new Todo();
        todo.setTitle(title);
        todo.setCompleted(false);

        TodoStep step = new TodoStep();
        step.setItems(items);
        step.setCompleted(completed);
        step.setTodo(todo);

        todo.setSteps(new java.util.ArrayList<>(List.of(step)));
        Todo saved = todoRepository.save(todo);
        return saved.getSteps().get(0);
    }
}
