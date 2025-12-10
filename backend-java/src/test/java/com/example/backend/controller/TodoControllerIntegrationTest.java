package com.example.backend.controller;

import com.example.backend.model.Todo;
import com.example.backend.repository.TodoRepository;
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



}
