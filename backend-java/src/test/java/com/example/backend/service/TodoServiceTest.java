package com.example.backend.service;

import com.example.backend.dtos.TodoRequestDTO;
import com.example.backend.dtos.TodoStepRequestDTO;
import com.example.backend.model.Todo;
import com.example.backend.model.TodoStep;
import com.example.backend.repository.TodoRepository;
import com.example.backend.repository.TodoStepRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("TodoService Unit Tests")
public class TodoServiceTest {

    @Mock
    private TodoRepository todoRepository;

    @Mock
    private TodoStepRepository todoStepRepository;

    @InjectMocks
    private TodoService todoService;

    @Captor
    private ArgumentCaptor<Todo> todoCaptor;

    @BeforeEach
    void setUp() {


    }
    //=======Test cho getAllTodos()========
    @Test
    @DisplayName("Tra ve list rong khi khong co Todo nao")
    void test_getAllTodos_shouldReturnEmptyList_whenNoTodos() {
        // Arrange
        when(todoRepository.findAll()).thenReturn(Collections.emptyList());
        // Act
        List<Todo> result = todoService.getAllTodos();
        // Assert
        assertNotNull(result);
        assertTrue(result.isEmpty());
        verify(todoRepository, times(1)).findAll();
        verifyNoMoreInteractions(todoRepository);
    }



    @Test
    @DisplayName("Tra ve tat ca cac Todo ton tai  trong DB")
    void test_getAllTodos_shouldReturnAllTodos_whenTodosExist() {
        // Arrange
        List<Todo> mockTodos = new ArrayList<>();
        mockTodos.add(new Todo(1L, "Todo 1", false, new ArrayList<>()));
        mockTodos.add(new Todo(2L, "Todo 2", true, new ArrayList<>()));
        mockTodos.add(new Todo(3L, "Todo 3", false, new ArrayList<>()));
        when(todoRepository.findAll()).thenReturn(mockTodos);

        // Act
        List<Todo> result = todoService.getAllTodos();
        // Assert
        assertNotNull(result);
        assertEquals(3, result.size());
        assertEquals("Todo 1", result.get(0).getTitle());
        assertEquals("Todo 2", result.get(1).getTitle());
        assertEquals("Todo 3", result.get(2).getTitle());
        verify(todoRepository, times(1)).findAll();
        verifyNoMoreInteractions(todoRepository);
    }

    //==========Test cho createTodo==========

    @Test
    @DisplayName("Title hop le, khong co steps")
    void test_createTodo_shouldCreateSuccessfully_withValidData() {
        // Arrange
        TodoRequestDTO request = new TodoRequestDTO();
        request.setTitle("Buy milk");
        when(todoRepository.save(any(Todo.class))).thenAnswer(invocation -> {
            Todo t = invocation.getArgument(0);
            t.setId(1L);
            return t;
        });
        // Act
        Todo result = todoService.createTodo(request);
        // Assert
        verify(todoRepository, times(1)).save(todoCaptor.capture());
        Todo saved = todoCaptor.getValue();

        assertEquals("Buy milk", saved.getTitle());
        assertFalse(saved.isCompleted());
        assertNotNull(saved.getSteps());
        assertTrue(saved.getSteps().isEmpty());

        assertNotNull(result.getId());
        assertEquals("Buy milk", result.getTitle());
        assertFalse(result.isCompleted());
        assertTrue(result.getSteps().isEmpty());
    }


    @Test
    @DisplayName("Title hop le, co 2 steps trong request")
    void test_createTodo_shouldCreateWithSteps_whenStepsProvided() {
        // Arrange
        TodoRequestDTO request = new TodoRequestDTO();
        request.setTitle("Todo with steps");
        request.setCompleted(false);

        TodoStepRequestDTO step1 = new TodoStepRequestDTO();
        step1.setItems("Step 1");
        step1.setCompleted(false);

        TodoStepRequestDTO step2 = new TodoStepRequestDTO();
        step2.setItems("Step 2");
        step2.setCompleted(true);

        List<TodoStepRequestDTO> steps = new ArrayList<>();
        steps.add(step1);
        steps.add(step2);
        request.setSteps(steps);

        when(todoRepository.save(any(Todo.class))).thenAnswer(invocation -> {
            Todo t = invocation.getArgument(0);
            t.setId(10L);
            long stepId = 1L;
            for (TodoStep s : t.getSteps()) {
                s.setId(stepId++);
            }
            return t;
        });

        // Act
        Todo result = todoService.createTodo(request);

        // Assert
        verify(todoRepository, times(1)).save(todoCaptor.capture());
        Todo saved = todoCaptor.getValue();

        assertEquals("Todo with steps", saved.getTitle());
        assertFalse(saved.isCompleted());
        assertNotNull(saved.getSteps());
        assertEquals(2, saved.getSteps().size());

        TodoStep savedStep1 = saved.getSteps().get(0);
        TodoStep savedStep2 = saved.getSteps().get(1);

        assertEquals("Step 1", savedStep1.getItems());
        assertFalse(savedStep1.isCompleted());
        assertSame(saved, savedStep1.getTodo());

        assertEquals("Step 2", savedStep2.getItems());
        assertTrue(savedStep2.isCompleted());
        assertSame(saved, savedStep2.getTodo());

        assertEquals(10L, result.getId());
        assertEquals(2, result.getSteps().size());
    }


    @Test
    @DisplayName("Nem IllegalArgumentException  voi title null")
    void test_createTodo_shouldThrowException_whenTitleIsNull() {
        // Arrange
        TodoRequestDTO request = new TodoRequestDTO();
        request.setTitle(null);

        // Act + Assert
        IllegalArgumentException ex = assertThrows(
                IllegalArgumentException.class,
                () -> todoService.createTodo(request)
        );

        assertEquals("Todo title must not be empty", ex.getMessage());
        verify(todoRepository, never()).save(any(Todo.class));
    }


    @Test
    @DisplayName("Nem IllegalArgumentException  voi title chi co khoang trang")
    void test_createTodo_shouldThrowException_whenTitleIsEmpty() {
        // Arrange
        TodoRequestDTO request = new TodoRequestDTO();
        request.setTitle("   ");

        // Act + Assert
        IllegalArgumentException ex = assertThrows(
                IllegalArgumentException.class,
                () -> todoService.createTodo(request)
        );

        assertEquals("Todo title must not be empty", ex.getMessage());
        verify(todoRepository, never()).save(any(Todo.class));
    }


    @Test
    @DisplayName("Nem IllegalArgumentException co step nhung items cua step rong/ chi co khoang trang")
    void test_createTodo_shouldThrowException_whenStepItemsIsEmpty() {
        // Arrange
        TodoRequestDTO request = new TodoRequestDTO();
        request.setTitle("Todo with invalid step");

        TodoStepRequestDTO step = new TodoStepRequestDTO();
        step.setItems("  ");
        step.setCompleted(false);

        List<TodoStepRequestDTO> steps = new ArrayList<>();
        steps.add(step);
        request.setSteps(steps);

        // Act + Assert
        IllegalArgumentException ex = assertThrows(
                IllegalArgumentException.class,
                () -> todoService.createTodo(request)
        );

        assertEquals("Step items must not be empty", ex.getMessage());
        verify(todoRepository, never()).save(any(Todo.class));
    }
}
