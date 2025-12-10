package com.example.backend.service;

import com.example.backend.dtos.TodoStepUpdateDTO;
import com.example.backend.dtos.TodoUpdateDTO;
import com.example.backend.model.Todo;
import com.example.backend.model.TodoStep;
import com.example.backend.repository.TodoRepository;
import com.example.backend.repository.TodoStepRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * ============================================
 * Unit Tests cho TodoService sử dụng Mockito
 * ============================================
 * 
 * Giải thích cơ chế:
 * - @Mock: Tạo mock object cho dependency (Repository)
 * - @InjectMocks: Tự động inject các mock vào service
 * - given-when-then: Pattern để viết test rõ ràng
 * 
 * Lợi ích:
 * - Độc lập với database thực (dùng H2)
 * - Test chỉ focus vào logic của Service
 * - Chạy nhanh vì không cần khởi tạo Spring Context
 */
@ExtendWith(MockitoExtension.class)  // Sử dụng Mockito
@DisplayName("TodoService Unit Tests - updateTodo, deleteTodo, updateStep, deleteStep")
class TodoServiceTest {

    // ============================================
    // SETUP: Khởi tạo Mocks và Service
    // ============================================

    @Mock
    private TodoRepository todoRepository;

    @Mock
    private TodoStepRepository todoStepRepository;

    @InjectMocks
    private TodoService todoService;

    /**
     * Chạy trước mỗi test để reset các mock objects
     * Điều này đảm bảo mỗi test độc lập với nhau
     */
    @BeforeEach
    void setUp() {
        // Mockito tự động reset mocks sau mỗi test
        // Không cần làm gì thêm
    }

    // ============================================
    // TEST updateTodo() - 4 test cases
    // ============================================

    /**
     * Test Case 1: updateTodo với title mới
     * 
     * Kịch bản:
     * - Setup: Tạo 1 Todo có title = "Old Title"
     * - Action: Update title thành "New Title"
     * - Verify: Title thực sự được cập nhật
     */
    @Test
    @DisplayName("✅ test_updateTodo_shouldUpdateTitle_whenTitleProvided")
    void test_updateTodo_shouldUpdateTitle_whenTitleProvided() {
        // Given (Setup dữ liệu)
        Long todoId = 1L;
        Todo existingTodo = new Todo();
        existingTodo.setId(todoId);
        existingTodo.setTitle("Old Title");
        existingTodo.setCompleted(false);
        existingTodo.setSteps(new ArrayList<>());

        TodoUpdateDTO updateDTO = new TodoUpdateDTO();
        updateDTO.setTitle("New Title");
        updateDTO.setCompleted(null);  // Không thay đổi trạng thái

        // Mock repository: Khi gọi findById(1L) thì trả về existingTodo
        when(todoRepository.findById(todoId)).thenReturn(Optional.of(existingTodo));
        // Mock repository: Khi gọi save() thì trả về existingTodo đã update
        when(todoRepository.save(any(Todo.class))).thenReturn(existingTodo);

        // When (Thực hiện hành động)
        Optional<Todo> result = todoService.updateTodo(todoId, updateDTO);

        // Then (Kiểm tra kết quả)
        assertTrue(result.isPresent(), "Result phải không rỗng");
        assertEquals("New Title", result.get().getTitle(), "Title phải được update thành 'New Title'");
        
        // Verify: Kiểm tra các method được gọi đúng lần
        verify(todoRepository, times(1)).findById(todoId);
        verify(todoRepository, times(1)).save(any(Todo.class));
    }

    /**
     * Test Case 2: updateTodo với completed = true
     * 
     * Kịch bản:
     * - Setup: Tạo 1 Todo với completed = false
     * - Action: Update completed thành true
     * - Verify: Todo.completed = true
     */
    @Test
    @DisplayName("✅ test_updateTodo_shouldUpdateCompleted_whenCompletedProvided")
    void test_updateTodo_shouldUpdateCompleted_whenCompletedProvided() {
        // Given
        Long todoId = 1L;
        Todo existingTodo = new Todo();
        existingTodo.setId(todoId);
        existingTodo.setTitle("Test Todo");
        existingTodo.setCompleted(false);
        existingTodo.setSteps(new ArrayList<>());

        TodoUpdateDTO updateDTO = new TodoUpdateDTO();
        updateDTO.setTitle(null);  // Không thay đổi title
        updateDTO.setCompleted(true);  // Update completed

        when(todoRepository.findById(todoId)).thenReturn(Optional.of(existingTodo));
        when(todoRepository.save(any(Todo.class))).thenReturn(existingTodo);

        // When
        Optional<Todo> result = todoService.updateTodo(todoId, updateDTO);

        // Then
        assertTrue(result.isPresent());
        assertTrue(result.get().isCompleted(), "Todo.completed phải bằng true");
        
        verify(todoRepository).findById(todoId);
        verify(todoRepository).save(any(Todo.class));
    }

    /**
     * Test Case 3: updateTodo với completed = true (Cascade)
     * 
     * Kịch bản:
     * - Setup: Tạo 1 Todo có 2 steps, cả 2 đều chưa hoàn thành
     * - Action: Update todo completed = true
     * - Verify: Cả 2 steps cũng được đánh dấu completed = true (Cascade)
     * 
     * Lý do: Khi Todo hoàn thành, tất cả steps con phải hoàn thành
     */
    @Test
    @DisplayName("✅ test_updateTodo_shouldUpdateStepsCompleted_whenTodoCompletedTrue")
    void test_updateTodo_shouldUpdateStepsCompleted_whenTodoCompletedTrue() {
        // Given
        Long todoId = 1L;
        Todo existingTodo = new Todo();
        existingTodo.setId(todoId);
        existingTodo.setTitle("Test Todo with Steps");
        existingTodo.setCompleted(false);

        // Tạo 2 steps chưa hoàn thành
        TodoStep step1 = new TodoStep();
        step1.setId(1L);
        step1.setItems("Step 1");
        step1.setCompleted(false);
        step1.setTodo(existingTodo);

        TodoStep step2 = new TodoStep();
        step2.setId(2L);
        step2.setItems("Step 2");
        step2.setCompleted(false);
        step2.setTodo(existingTodo);

        List<TodoStep> steps = new ArrayList<>();
        steps.add(step1);
        steps.add(step2);
        existingTodo.setSteps(steps);

        TodoUpdateDTO updateDTO = new TodoUpdateDTO();
        updateDTO.setTitle(null);
        updateDTO.setCompleted(true);  // Mark todo as completed

        when(todoRepository.findById(todoId)).thenReturn(Optional.of(existingTodo));
        when(todoRepository.save(any(Todo.class))).thenReturn(existingTodo);

        // When
        Optional<Todo> result = todoService.updateTodo(todoId, updateDTO);

        // Then
        assertTrue(result.isPresent());
        assertTrue(result.get().isCompleted(), "Todo phải completed");
        
        // Verify: Cả 2 steps đều completed
        for (TodoStep step : result.get().getSteps()) {
            assertTrue(step.isCompleted(), 
                "Tất cả steps phải completed khi todo completed = true");
        }
        
        verify(todoRepository).findById(todoId);
        verify(todoRepository).save(any(Todo.class));
    }

    /**
     * Test Case 4: updateTodo khi Todo không tồn tại
     * 
     * Kịch bản:
     * - Setup: Tìm Todo với id không tồn tại
     * - Verify: Return Optional.empty()
     * 
     * Lý do: Phải xử lý gracefully khi resource không tìm thấy
     */
    @Test
    @DisplayName("✅ test_updateTodo_shouldReturnEmpty_whenTodoNotFound")
    void test_updateTodo_shouldReturnEmpty_whenTodoNotFound() {
        // Given
        Long nonExistentId = 999L;
        TodoUpdateDTO updateDTO = new TodoUpdateDTO();
        updateDTO.setTitle("New Title");

        // Mock: Repository không tìm thấy Todo
        when(todoRepository.findById(nonExistentId)).thenReturn(Optional.empty());

        // When
        Optional<Todo> result = todoService.updateTodo(nonExistentId, updateDTO);

        // Then
        assertTrue(result.isEmpty(), "Result phải rỗng khi Todo không tồn tại");
        
        // Verify: save() không được gọi vì Todo không tồn tại
        verify(todoRepository, never()).save(any(Todo.class));
    }

    // ============================================
    // TEST deleteTodo() - 2 test cases
    // ============================================

    /**
     * Test Case 5: deleteTodo khi Todo tồn tại
     * 
     * Kịch bản:
     * - Setup: Tạo 1 Todo tồn tại
     * - Action: Xóa Todo
     * - Verify: Return true, todo bị xóa khỏi DB
     */
    @Test
    @DisplayName("✅ test_deleteTodo_shouldReturnTrue_whenTodoExists")
    void test_deleteTodo_shouldReturnTrue_whenTodoExists() {
        // Given
        Long todoId = 1L;
        Todo existingTodo = new Todo();
        existingTodo.setId(todoId);
        existingTodo.setTitle("To be deleted");
        existingTodo.setSteps(new ArrayList<>());

        // Mock: Repository tìm thấy Todo
        when(todoRepository.findById(todoId)).thenReturn(Optional.of(existingTodo));

        // When
        boolean result = todoService.deleteTodo(todoId);

        // Then
        assertTrue(result, "Method phải return true");
        
        // Verify: delete() được gọi đúng 1 lần
        verify(todoRepository, times(1)).findById(todoId);
        verify(todoRepository, times(1)).delete(existingTodo);
    }

    /**
     * Test Case 6: deleteTodo khi Todo không tồn tại
     * 
     * Kịch bản:
     * - Setup: Tìm Todo với id không tồn tại
     * - Verify: Return false, không gọi delete()
     */
    @Test
    @DisplayName("✅ test_deleteTodo_shouldReturnFalse_whenTodoNotFound")
    void test_deleteTodo_shouldReturnFalse_whenTodoNotFound() {
        // Given
        Long nonExistentId = 999L;
        when(todoRepository.findById(nonExistentId)).thenReturn(Optional.empty());

        // When
        boolean result = todoService.deleteTodo(nonExistentId);

        // Then
        assertFalse(result, "Method phải return false");
        
        // Verify: delete() không được gọi
        verify(todoRepository, never()).delete(any(Todo.class));
    }

    // ============================================
    // TEST updateStep() - 5 test cases
    // ============================================

    /**
     * Test Case 7: updateStep với items mới
     * 
     * Kịch bản:
     * - Setup: Tạo 1 Step có items = "Old Items"
     * - Action: Update items = "New Items"
     * - Verify: Items được cập nhật
     */
    @Test
    @DisplayName("✅ test_updateStep_shouldUpdateItems_whenItemsProvided")
    void test_updateStep_shouldUpdateItems_whenItemsProvided() {
        // Given
        Long stepId = 1L;
        Todo parentTodo = new Todo();
        parentTodo.setId(1L);
        parentTodo.setTitle("Parent Todo");
        parentTodo.setCompleted(false);

        TodoStep existingStep = new TodoStep();
        existingStep.setId(stepId);
        existingStep.setItems("Old Items");
        existingStep.setCompleted(false);
        existingStep.setTodo(parentTodo);

        parentTodo.getSteps().add(existingStep);

        TodoStepUpdateDTO updateDTO = new TodoStepUpdateDTO();
        updateDTO.setItems("New Items");
        updateDTO.setCompleted(null);

        when(todoStepRepository.findById(stepId)).thenReturn(Optional.of(existingStep));
        when(todoStepRepository.save(any(TodoStep.class))).thenReturn(existingStep);
        when(todoRepository.save(any(Todo.class))).thenReturn(parentTodo);

        // When
        Optional<TodoStep> result = todoService.updateStep(stepId, updateDTO);

        // Then
        assertTrue(result.isPresent());
        assertEquals("New Items", result.get().getItems(), "Items phải được cập nhật");
        
        verify(todoStepRepository).findById(stepId);
        verify(todoStepRepository).save(any(TodoStep.class));
    }

    /**
     * Test Case 8: updateStep với completed = true
     * 
     * Kịch bản:
     * - Setup: Tạo 1 Step với completed = false
     * - Action: Update completed = true
     * - Verify: Step.completed = true
     */
    @Test
    @DisplayName("✅ test_updateStep_shouldUpdateCompleted_whenCompletedProvided")
    void test_updateStep_shouldUpdateCompleted_whenCompletedProvided() {
        // Given
        Long stepId = 1L;
        Todo parentTodo = new Todo();
        parentTodo.setId(1L);
        parentTodo.setCompleted(false);

        TodoStep existingStep = new TodoStep();
        existingStep.setId(stepId);
        existingStep.setItems("Test Step");
        existingStep.setCompleted(false);
        existingStep.setTodo(parentTodo);

        parentTodo.getSteps().add(existingStep);

        TodoStepUpdateDTO updateDTO = new TodoStepUpdateDTO();
        updateDTO.setItems(null);
        updateDTO.setCompleted(true);

        when(todoStepRepository.findById(stepId)).thenReturn(Optional.of(existingStep));
        when(todoStepRepository.save(any(TodoStep.class))).thenReturn(existingStep);
        when(todoRepository.save(any(Todo.class))).thenReturn(parentTodo);

        // When
        Optional<TodoStep> result = todoService.updateStep(stepId, updateDTO);

        // Then
        assertTrue(result.isPresent());
        assertTrue(result.get().isCompleted(), "Step phải completed");
        
        verify(todoStepRepository).findById(stepId);
        verify(todoStepRepository).save(any(TodoStep.class));
    }

    /**
     * Test Case 9: updateStep - Cascade parent completion
     * 
     * Kịch bản:
     * - Setup: Todo có 2 steps, 1 step đã completed, 1 step chưa
     * - Action: Update step còn lại thành completed = true
     * - Verify: Parent todo.completed = true (vì tất cả steps đều completed)
     * 
     * Lý do: Nếu tất cả steps hoàn thành, todo cha cũng phải hoàn thành
     */
    @Test
    @DisplayName("✅ test_updateStep_shouldUpdateParentCompleted_whenAllStepsCompleted")
    void test_updateStep_shouldUpdateParentCompleted_whenAllStepsCompleted() {
        // Given
        Long stepId = 2L;
        Todo parentTodo = new Todo();
        parentTodo.setId(1L);
        parentTodo.setTitle("Parent Todo");
        parentTodo.setCompleted(false);

        // Step 1: Đã completed
        TodoStep step1 = new TodoStep();
        step1.setId(1L);
        step1.setItems("Step 1");
        step1.setCompleted(true);
        step1.setTodo(parentTodo);

        // Step 2: Chưa completed (cái này sẽ update)
        TodoStep step2 = new TodoStep();
        step2.setId(stepId);
        step2.setItems("Step 2");
        step2.setCompleted(false);
        step2.setTodo(parentTodo);

        List<TodoStep> steps = new ArrayList<>();
        steps.add(step1);
        steps.add(step2);
        parentTodo.setSteps(steps);

        TodoStepUpdateDTO updateDTO = new TodoStepUpdateDTO();
        updateDTO.setItems(null);
        updateDTO.setCompleted(true);  // Update step 2 thành completed

        when(todoStepRepository.findById(stepId)).thenReturn(Optional.of(step2));
        when(todoStepRepository.save(any(TodoStep.class))).thenReturn(step2);
        when(todoRepository.save(any(Todo.class))).thenReturn(parentTodo);

        // When
        Optional<TodoStep> result = todoService.updateStep(stepId, updateDTO);

        // Then
        assertTrue(result.isPresent());
        // Verify: Parent todo phải completed vì tất cả steps completed
        assertTrue(parentTodo.isCompleted(), 
            "Parent todo phải completed vì tất cả steps completed");
        
        verify(todoStepRepository).findById(stepId);
        verify(todoRepository).save(parentTodo);
    }

    /**
     * Test Case 10: updateStep với items trống (validation)
     * 
     * Kịch bản:
     * - Setup: Tạo 1 Step
     * - Action: Update items = "   " (chỉ có spaces)
     * - Verify: Throw IllegalArgumentException
     * 
     * Lý do: Không được phép để items rỗng
     */
    @Test
    @DisplayName("✅ test_updateStep_shouldThrowException_whenItemsIsBlank")
    void test_updateStep_shouldThrowException_whenItemsIsBlank() {
        // Given
        Long stepId = 1L;
        Todo parentTodo = new Todo();
        parentTodo.setId(1L);

        TodoStep existingStep = new TodoStep();
        existingStep.setId(stepId);
        existingStep.setItems("Original Items");
        existingStep.setTodo(parentTodo);

        TodoStepUpdateDTO updateDTO = new TodoStepUpdateDTO();
        updateDTO.setItems("   ");  // Chỉ có spaces - INVALID

        when(todoStepRepository.findById(stepId)).thenReturn(Optional.of(existingStep));

        // When & Then
        assertThrows(IllegalArgumentException.class, 
            () -> todoService.updateStep(stepId, updateDTO),
            "Phải throw IllegalArgumentException khi items trống");
        
        // Verify: save() không được gọi vì validate fail
        verify(todoStepRepository, never()).save(any(TodoStep.class));
    }

    /**
     * Test Case 11: updateStep khi Step không tồn tại
     * 
     * Kịch bản:
     * - Setup: Tìm Step với id không tồn tại
     * - Verify: Return Optional.empty()
     */
    @Test
    @DisplayName("✅ test_updateStep_shouldReturnEmpty_whenStepNotFound")
    void test_updateStep_shouldReturnEmpty_whenStepNotFound() {
        // Given
        Long nonExistentId = 999L;
        TodoStepUpdateDTO updateDTO = new TodoStepUpdateDTO();
        updateDTO.setItems("New Items");

        when(todoStepRepository.findById(nonExistentId)).thenReturn(Optional.empty());

        // When
        Optional<TodoStep> result = todoService.updateStep(nonExistentId, updateDTO);

        // Then
        assertTrue(result.isEmpty(), "Result phải rỗng khi Step không tồn tại");
        
        verify(todoStepRepository, never()).save(any(TodoStep.class));
    }

    // ============================================
    // TEST deleteStep() - 3 test cases
    // ============================================

    /**
     * Test Case 12: deleteStep khi Step tồn tại
     * 
     * Kịch bản:
     * - Setup: Tạo 1 Step tồn tại
     * - Action: Xóa Step
     * - Verify: Return true, step bị xóa
     */
    @Test
    @DisplayName("✅ test_deleteStep_shouldReturnTrue_whenStepExists")
    void test_deleteStep_shouldReturnTrue_whenStepExists() {
        // Given
        Long stepId = 1L;
        Todo parentTodo = new Todo();
        parentTodo.setId(1L);
        parentTodo.setCompleted(true);

        TodoStep existingStep = new TodoStep();
        existingStep.setId(stepId);
        existingStep.setItems("Step to delete");
        existingStep.setTodo(parentTodo);

        parentTodo.getSteps().add(existingStep);

        when(todoStepRepository.findById(stepId)).thenReturn(Optional.of(existingStep));
        when(todoRepository.save(any(Todo.class))).thenReturn(parentTodo);

        // When
        boolean result = todoService.deleteStep(stepId);

        // Then
        assertTrue(result, "Method phải return true");
        
        verify(todoStepRepository, times(1)).findById(stepId);
        verify(todoStepRepository, times(1)).delete(existingStep);
    }

    /**
     * Test Case 13: deleteStep - Cascade parent completion
     * 
     * Kịch bản:
     * - Setup: Todo có 2 steps (1 completed, 1 not completed)
     * - Action: Delete step chưa completed
     * - Verify: Parent todo.completed = true (vì step còn lại đã completed)
     * 
     * Lý do: Sau khi xóa, nếu tất cả steps còn lại completed, todo cha cũng completed
     */
    @Test
    @DisplayName("✅ test_deleteStep_shouldUpdateParentCompleted_whenAllRemainingStepsCompleted")
    void test_deleteStep_shouldUpdateParentCompleted_whenAllRemainingStepsCompleted() {
        // Given
        Long stepToDeleteId = 2L;
        Todo parentTodo = new Todo();
        parentTodo.setId(1L);
        parentTodo.setCompleted(false);

        // Step 1: Đã completed - sẽ KHÔNG bị xóa
        TodoStep step1 = new TodoStep();
        step1.setId(1L);
        step1.setItems("Step 1");
        step1.setCompleted(true);
        step1.setTodo(parentTodo);

        // Step 2: Chưa completed - cái này sẽ bị DELETE
        TodoStep step2 = new TodoStep();
        step2.setId(stepToDeleteId);
        step2.setItems("Step 2");
        step2.setCompleted(false);
        step2.setTodo(parentTodo);

        List<TodoStep> steps = new ArrayList<>();
        steps.add(step1);
        steps.add(step2);
        parentTodo.setSteps(steps);

        when(todoStepRepository.findById(stepToDeleteId)).thenReturn(Optional.of(step2));
        when(todoRepository.save(any(Todo.class))).thenReturn(parentTodo);

        // When
        boolean result = todoService.deleteStep(stepToDeleteId);

        // Then
        assertTrue(result, "Method phải return true");
        // Verify: Parent todo phải completed vì step còn lại đã completed
        assertTrue(parentTodo.isCompleted(), 
            "Parent todo phải completed vì tất cả remaining steps completed");
        
        verify(todoStepRepository).delete(step2);
        verify(todoRepository).save(parentTodo);
    }

    /**
     * Test Case 14: deleteStep khi Step không tồn tại
     * 
     * Kịch bản:
     * - Setup: Tìm Step với id không tồn tại
     * - Verify: Return false, không gọi delete()
     */
    @Test
    @DisplayName("✅ test_deleteStep_shouldReturnFalse_whenStepNotFound")
    void test_deleteStep_shouldReturnFalse_whenStepNotFound() {
        // Given
        Long nonExistentId = 999L;
        when(todoStepRepository.findById(nonExistentId)).thenReturn(Optional.empty());

        // When
        boolean result = todoService.deleteStep(nonExistentId);

        // Then
        assertFalse(result, "Method phải return false");
        
        // Verify: delete() không được gọi
        verify(todoStepRepository, never()).delete(any(TodoStep.class));
    }

}
