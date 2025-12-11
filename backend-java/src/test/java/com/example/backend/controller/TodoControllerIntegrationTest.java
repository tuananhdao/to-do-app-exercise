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
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.WebApplicationContext;
import java.util.List;
import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
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

public class TodoControllerIntegrationTest {

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
        this.mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
    }

    // =========================
    // GET /api/v1/todos
    // =========================

    @Test
    void test_getAllTodos_shouldReturn200_withEmptyList() throws Exception {
        mockMvc.perform(get("/api/v1/todos"))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(1000))
                .andExpect(jsonPath("$.message").value("Success"))
                .andExpect(jsonPath("$.result").isArray())
                .andExpect(jsonPath("$.result.length()").value(0));
    }

    @Test
    void test_getAllTodos_shouldReturn200_withTodosList() throws Exception {
        Todo todo1 = new Todo();
        todo1.setTitle("Todo 1");
        todo1.setCompleted(false);

        Todo todo2 = new Todo();
        todo2.setTitle("Todo 2");
        todo2.setCompleted(true);

        todoRepository.save(todo1);
        todoRepository.save(todo2);

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

    // =========================
    // POST /api/v1/todos
    // =========================

    @Test
    void test_createTodo_shouldReturn200_withValidData() throws Exception {
        String requestJson = """
                {
                  "title": "Buy milk",
                  "completed": false
                }
                """;

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

        List<Todo> todos = todoRepository.findAll();
        assertEquals(1, todos.size());
        assertEquals("Buy milk", todos.get(0).getTitle());
        assertFalse(todos.get(0).isCompleted());
    }

    @Test
    void test_createTodo_shouldReturn200_withSteps() throws Exception {
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

        List<Todo> todos = todoRepository.findAll();
        assertEquals(1, todos.size());
        assertEquals(2, todos.get(0).getSteps().size());
    }

    @Test
    void test_createTodo_shouldReturn400_whenTitleIsNull() throws Exception {
        String requestJson = """
                {
                  "completed": false
                }
                """;

        mockMvc.perform(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestJson))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(9999))
                .andExpect(jsonPath("$.message").value("Title must not be empty"));
    }

    @Test
    void test_createTodo_shouldReturn400_whenTitleIsBlank() throws Exception {
        String requestJson = """
                {
                  "title": " "
                }
                """;

        mockMvc.perform(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestJson))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(9999))
                .andExpect(jsonPath("$.message").value("Title must not be empty"));
    }

    @Test
    void test_createTodo_shouldReturn400_whenStepItemsIsBlank() throws Exception {
        String requestJson = """
                {
                  "title": "Todo with invalid step",
                  "completed": false,
                  "steps": [
                    { "items": "", "completed": false }
                  ]
                }
                """;

        mockMvc.perform(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestJson))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(9999))
                .andExpect(jsonPath("$.message").value("Step items must not be empty"));
    }


    // =========================
    // POST /api/v1/todos/{todoId}/items
    // =========================

    @Test
    @DisplayName("POST /todos/{todoId}/items - add step successfully -> 200")
    void test_addStepToTodo_shouldReturn200_whenValidRequest() throws Exception {
        // Arrange: tạo 1 todo cha
        Todo todo = new Todo();
        todo.setTitle("Parent todo");
        todo.setCompleted(false);
        todo = todoRepository.save(todo);

        String requestJson = """
                {
                  "items": "New step",
                  "completed": true
                }
                """;

        // Act + Assert
        mockMvc.perform(post("/api/v1/todos/{todoId}/items", todo.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestJson))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(1000))
                .andExpect(jsonPath("$.message").value("Success"))
                .andExpect(jsonPath("$.result.id").value(todo.getId().intValue()))
                .andExpect(jsonPath("$.result.steps").isArray())
                .andExpect(jsonPath("$.result.steps.length()").value(1))
                .andExpect(jsonPath("$.result.steps[0].items").value("New step"))
                .andExpect(jsonPath("$.result.steps[0].completed").value(true));


        Todo reloaded = todoRepository.findById(todo.getId()).orElseThrow();
        assertThat(reloaded.getSteps()).hasSize(1);
        assertThat(reloaded.getSteps().get(0).getItems()).isEqualTo("New step");
        assertThat(reloaded.getSteps().get(0).isCompleted()).isTrue();
    }

    @Test
    @DisplayName("POST /todos/{todoId}/items - blank items -> 400")
    void test_addStepToTodo_shouldReturn400_whenItemsBlank() throws Exception {
        Todo todo = new Todo();
        todo.setTitle("Parent todo");
        todo.setCompleted(false);
        todo = todoRepository.save(todo);

        String requestJson = """
                {
                  "items": " ",
                  "completed": false
                }
                """;

        mockMvc.perform(post("/api/v1/todos/{todoId}/items", todo.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestJson))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(9999))
                .andExpect(jsonPath("$.message").value("Step items must not be empty"));
    }

    @Test
    @DisplayName("POST /todos/{todoId}/items - todo not found -> 404")
    void test_addStepToTodo_shouldReturn404_whenTodoNotFound() throws Exception {
        String requestJson = """
                {
                  "items": "New step",
                  "completed": false
                }
                """;

        mockMvc.perform(post("/api/v1/todos/{todoId}/items", 999)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestJson))
                .andExpect(status().isNotFound())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.code").value(404))
                .andExpect(jsonPath("$.message").value("Todo not found with id: 999"));
    }

    // PATCH /api/v1/todos/{id}


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

        TodoStep step = createTodoWithSingleStep("Old items", false);

        mockMvc.perform(patch("/api/v1/todos/items/{id}", step.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\"Updated items\"}"))

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

        TodoStep step = createTodoWithSingleStep("Work", false);

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

        TodoStep step = createTodoWithSingleStep("Work", false);

        mockMvc.perform(patch("/api/v1/todos/items/{id}", step.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"text\":\" \"}"))
                .andExpect(status().isBadRequest());

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

        TodoStep step = createTodoWithSingleStep("Step", false);

        mockMvc.perform(delete("/api/v1/todos/items/{id}", step.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.result").value("Step deleted successfully"));

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


    private TodoStep createTodoWithSingleStep(String items, boolean completed) {
        Todo todo = new Todo();
        todo.setTitle("Todo");

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
