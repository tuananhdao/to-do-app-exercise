package com.example.backend.controller;

import com.example.backend.model.Todo;
import com.example.backend.model.TodoStep;
import com.example.backend.repository.TodoRepository;
import com.example.backend.repository.TodoStepRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
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
