# Hướng Dẫn Viết Test

## 🔧 Backend Testing (Java/Spring Boot)

### Chạy Test
```bash
cd backend-java
mvn test
```

### Cấu Trúc Test
```
src/test/java/com/example/backend/
├── service/          # Unit tests - Test business logic
├── controller/       # Integration tests - Test API endpoints
└── repository/       # Repository tests - Test database operations
```

### Setup Test Environment (CHỈ LÀM 1 LẦN)

#### 1. Tạo file cấu hình test
Tạo file `src/test/resources/application-test.properties`:
```properties
# Sử dụng H2 in-memory database cho test
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect

# Tự động tạo/xóa schema
spring.jpa.hibernate.ddl-auto=create-drop

# Hiển thị SQL để debug (tùy chọn)
spring.jpa.show-sql=true
```

#### 2. Các annotation quan trọng
- **`@SpringBootTest`** - Load toàn bộ application context (cho integration test)
- **`@WebMvcTest`** - Chỉ load controller layer (nhanh hơn)
- **`@DataJpaTest`** - Chỉ load JPA components (test repository)
- **`@MockBean`** - Mock dependencies (ví dụ: mock service trong controller test)
- **`@Transactional`** - Tự động rollback sau mỗi test (giữ DB sạch)

---

### 📝 Ví Dụ Chi Tiết

#### A. Unit Test - Test Service Layer

**File**: `src/test/java/com/example/backend/service/TodoServiceTest.java`

```java
package com.example.backend.service;

import com.example.backend.dtos.TodoRequestDTO;
import com.example.backend.model.Todo;
import com.example.backend.repository.TodoRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class) // Sử dụng Mockito
@DisplayName("TodoService Unit Tests")
class TodoServiceTest {

    @Mock // Mock dependency
    private TodoRepository todoRepository;

    @InjectMocks // Tự động inject các mock vào service
    private TodoService todoService;

    private TodoRequestDTO validRequest;

    @BeforeEach // Chạy trước mỗi test
    void setUp() {
        validRequest = new TodoRequestDTO();
        validRequest.setTitle("Test Todo");
        validRequest.setCompleted(false);
    }

    @Test
    @DisplayName("Nên tạo todo thành công với dữ liệu hợp lệ")
    void shouldCreateTodo_WithValidData() {
        // Given - Chuẩn bị dữ liệu
        Todo savedTodo = new Todo();
        savedTodo.setId(1L);
        savedTodo.setTitle("Test Todo");
        savedTodo.setCompleted(false);
        
        // Mock repository trả về todo đã lưu
        when(todoRepository.save(any(Todo.class))).thenReturn(savedTodo);

        // When - Thực hiện hành động
        Todo result = todoService.createTodo(validRequest);

        // Then - Kiểm tra kết quả
        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("Test Todo", result.getTitle());
        assertFalse(result.isCompleted());
        
        // Verify repository được gọi đúng 1 lần
        verify(todoRepository, times(1)).save(any(Todo.class));
    }

    @Test
    @DisplayName("Nên throw exception khi title null")
    void shouldThrowException_WhenTitleIsNull() {
        // Given
        validRequest.setTitle(null);

        // When & Then
        assertThrows(IllegalArgumentException.class, () -> {
            todoService.createTodo(validRequest);
        });
        
        // Verify repository KHÔNG được gọi
        verify(todoRepository, never()).save(any());
    }

    @Test
    @DisplayName("Nên lấy được tất cả todos")
    void shouldGetAllTodos() {
        // Given
        Todo todo1 = new Todo();
        todo1.setId(1L);
        todo1.setTitle("Todo 1");
        
        Todo todo2 = new Todo();
        todo2.setId(2L);
        todo2.setTitle("Todo 2");
        
        when(todoRepository.findAll()).thenReturn(Arrays.asList(todo1, todo2));

        // When
        List<Todo> result = todoService.getAllTodos();

        // Then
        assertEquals(2, result.size());
        assertEquals("Todo 1", result.get(0).getTitle());
        verify(todoRepository).findAll();
    }
}
```

---

#### B. Integration Test - Test Controller + Service + Repository

**File**: `src/test/java/com/example/backend/controller/TodoControllerIntegrationTest.java`

```java
package com.example.backend.controller;

import com.example.backend.dtos.TodoRequestDTO;
import com.example.backend.model.Todo;
import com.example.backend.repository.TodoRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest // Load toàn bộ application
@AutoConfigureMockMvc // Tự động config MockMvc
@ActiveProfiles("test") // Dùng application-test.properties
@Transactional // Rollback sau mỗi test
@DisplayName("TodoController Integration Tests")
class TodoControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc; // Để gọi API

    @Autowired
    private TodoRepository todoRepository;

    @Autowired
    private ObjectMapper objectMapper; // Convert object -> JSON

    @BeforeEach
    void setUp() {
        // Xóa sạch database trước mỗi test
        todoRepository.deleteAll();
    }

    @Test
    @DisplayName("GET /api/v1/todos - Nên trả về danh sách rỗng")
    void shouldReturnEmptyList_WhenNoTodos() throws Exception {
        mockMvc.perform(get("/api/v1/todos"))
                .andExpect(status().isOk()) // HTTP 200
                .andExpect(jsonPath("$.code").value(1000))
                .andExpect(jsonPath("$.message").value("Success"))
                .andExpect(jsonPath("$.result").isArray())
                .andExpect(jsonPath("$.result", hasSize(0)));
    }

    @Test
    @DisplayName("POST /api/v1/todos - Nên tạo todo thành công")
    void shouldCreateTodo_WithValidData() throws Exception {
        // Given
        TodoRequestDTO request = new TodoRequestDTO();
        request.setTitle("Buy milk");
        request.setCompleted(false);

        // When & Then
        mockMvc.perform(post("/api/v1/todos")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(1000))
                .andExpect(jsonPath("$.result.title").value("Buy milk"))
                .andExpect(jsonPath("$.result.completed").value(false))
                .andExpect(jsonPath("$.result.id").exists());

        // Verify database có 1 record
        assertEquals(1, todoRepository.count());
    }

    @Test
    @DisplayName("POST /api/v1/todos - Nên trả về 400 khi title rỗng")
    void shouldReturn400_WhenTitleIsEmpty() throws Exception {
        // Given
        TodoRequestDTO request = new TodoRequestDTO();
        request.setTitle("");

        // When & Then
        mockMvc.perform(post("/api/v1/todos")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest()) // HTTP 400
                .andExpect(jsonPath("$.code").value(9999))
                .andExpect(jsonPath("$.message").value("Title must not be empty"));
    }

    @Test
    @DisplayName("PATCH /api/v1/todos/{id} - Nên update todo thành công")
    void shouldUpdateTodo_WithValidId() throws Exception {
        // Given - Tạo todo trước
        Todo todo = new Todo();
        todo.setTitle("Old Title");
        todo.setCompleted(false);
        todo = todoRepository.save(todo);

        // When & Then
        mockMvc.perform(patch("/api/v1/todos/" + todo.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"title\":\"New Title\",\"completed\":true}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.result.title").value("New Title"))
                .andExpect(jsonPath("$.result.completed").value(true));
    }

    @Test
    @DisplayName("DELETE /api/v1/todos/{id} - Nên xóa todo thành công")
    void shouldDeleteTodo_WithValidId() throws Exception {
        // Given
        Todo todo = new Todo();
        todo.setTitle("To be deleted");
        todo = todoRepository.save(todo);

        // When & Then
        mockMvc.perform(delete("/api/v1/todos/" + todo.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Deleted successfully"));

        // Verify todo đã bị xóa
        assertEquals(0, todoRepository.count());
    }
}
```

---

#### C. Repository Test

**File**: `src/test/java/com/example/backend/repository/TodoRepositoryTest.java`

```java
package com.example.backend.repository;

import com.example.backend.model.Todo;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest // Chỉ load JPA components
@ActiveProfiles("test")
@DisplayName("TodoRepository Tests")
class TodoRepositoryTest {

    @Autowired
    private TodoRepository todoRepository;

    @Test
    @DisplayName("Nên lưu và tìm todo theo ID")
    void shouldSaveAndFindById() {
        // Given
        Todo todo = new Todo();
        todo.setTitle("Test Todo");
        todo.setCompleted(false);

        // When
        Todo saved = todoRepository.save(todo);
        Todo found = todoRepository.findById(saved.getId()).orElse(null);

        // Then
        assertNotNull(found);
        assertEquals("Test Todo", found.getTitle());
        assertFalse(found.isCompleted());
    }

    @Test
    @DisplayName("Nên tìm tất cả todos")
    void shouldFindAllTodos() {
        // Given
        Todo todo1 = new Todo();
        todo1.setTitle("Todo 1");
        todoRepository.save(todo1);

        Todo todo2 = new Todo();
        todo2.setTitle("Todo 2");
        todoRepository.save(todo2);

        // When
        List<Todo> todos = todoRepository.findAll();

        // Then
        assertEquals(2, todos.size());
    }
}
```

---

## 🎨 Frontend Testing (React/Vitest)

### Setup (CHỈ LÀM 1 LẦN)

#### Bước 1: Cài đặt thư viện
```bash
cd frontend-react
npm install --save-dev vitest jsdom @testing-library/react @testing-library/jest-dom @testing-library/user-event
```

#### Bước 2: Bỏ comment trong setup file
Mở file `src/test/setup.js` và bỏ comment dòng này:
```javascript
import '@testing-library/jest-dom';
```

#### Bước 3: Xóa file placeholder
```bash
rm src/test/placeholder.test.js
```

---

### Chạy Test
```bash
npm test              # Chế độ watch (tự động chạy lại khi code thay đổi)
npm test -- --run     # Chạy 1 lần (giống CI)
npm run test:ui       # Chạy với giao diện đẹp
npm run test:coverage # Xem code coverage

# Khi được hỏi install package, chọn "y" (yes)
```

---

### 📝 Ví Dụ Chi Tiết

#### A. Test Component TodoForm

**File**: `src/components/todo/__tests__/TodoForm.test.jsx`

```javascript
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import TodoForm from '../TodoForm';

describe('TodoForm Component', () => {
  let mockOnAdd;

  beforeEach(() => {
    // Tạo mock function trước mỗi test
    mockOnAdd = vi.fn();
  });

  it('nên hiển thị input và button submit', () => {
    // Render component
    render(<TodoForm onAdd={mockOnAdd} />);
    
    // Kiểm tra có input field
    const input = screen.getByPlaceholderText(/what needs to be done/i);
    expect(input).toBeInTheDocument();
    
    // Kiểm tra có button
    const button = screen.getByText(/add todo/i);
    expect(button).toBeInTheDocument();
  });

  it('nên cho phép user gõ text vào input', async () => {
    const user = userEvent.setup();
    render(<TodoForm onAdd={mockOnAdd} />);
    
    const input = screen.getByPlaceholderText(/what needs to be done/i);
    
    // User gõ text
    await user.type(input, 'Buy milk');
    
    // Kiểm tra value
    expect(input).toHaveValue('Buy milk');
  });

  it('nên gọi onAdd khi submit form với text hợp lệ', async () => {
    const user = userEvent.setup();
    render(<TodoForm onAdd={mockOnAdd} />);
    
    // Gõ text
    const input = screen.getByPlaceholderText(/what needs to be done/i);
    await user.type(input, 'Buy milk');
    
    // Click button
    const button = screen.getByText(/add todo/i);
    await user.click(button);
    
    // Kiểm tra onAdd được gọi với đúng tham số
    expect(mockOnAdd).toHaveBeenCalledWith('Buy milk', []);
    expect(mockOnAdd).toHaveBeenCalledTimes(1);
  });

  it('KHÔNG nên gọi onAdd khi text rỗng', async () => {
    const user = userEvent.setup();
    render(<TodoForm onAdd={mockOnAdd} />);
    
    // Click button mà không gõ gì
    const button = screen.getByText(/add todo/i);
    await user.click(button);
    
    // onAdd không được gọi
    expect(mockOnAdd).not.toHaveBeenCalled();
  });

  it('nên xóa input sau khi submit thành công', async () => {
    const user = userEvent.setup();
    render(<TodoForm onAdd={mockOnAdd} />);
    
    const input = screen.getByPlaceholderText(/what needs to be done/i);
    await user.type(input, 'Buy milk');
    await user.click(screen.getByText(/add todo/i));
    
    // Input nên rỗng sau khi submit
    expect(input).toHaveValue('');
  });

  it('nên hiển thị section thêm steps khi click nút Add Steps', async () => {
    const user = userEvent.setup();
    render(<TodoForm onAdd={mockOnAdd} />);
    
    // Click nút Add Steps
    const addStepsBtn = screen.getByText(/add steps/i);
    await user.click(addStepsBtn);
    
    // Kiểm tra có input step xuất hiện
    const stepInput = screen.getByPlaceholderText(/step 1/i);
    expect(stepInput).toBeInTheDocument();
  });
});
```

---

#### B. Test Component TodoItem

**File**: `src/components/todo/__tests__/TodoItem.test.jsx`

```javascript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import TodoItem from '../TodoItem';

describe('TodoItem Component', () => {
  const mockTodo = {
    id: 1,
    text: 'Buy milk',
    completed: false,
    steps: []
  };

  it('nên hiển thị todo text và checkbox', () => {
    render(<TodoItem todo={mockTodo} onToggle={vi.fn()} />);
    
    // Kiểm tra text hiển thị
    expect(screen.getByText('Buy milk')).toBeInTheDocument();
    
    // Kiểm tra checkbox không được check
    const checkbox = screen.getByRole('checkbox');
    expect(checkbox).not.toBeChecked();
  });

  it('nên hiển thị checkbox được check khi todo completed', () => {
    const completedTodo = { ...mockTodo, completed: true };
    render(<TodoItem todo={completedTodo} onToggle={vi.fn()} />);
    
    const checkbox = screen.getByRole('checkbox');
    expect(checkbox).toBeChecked();
  });

  it('nên gọi onToggle khi click vào checkbox', async () => {
    const user = userEvent.setup();
    const mockToggle = vi.fn();
    render(<TodoItem todo={mockTodo} onToggle={mockToggle} />);
    
    const checkbox = screen.getByRole('checkbox');
    await user.click(checkbox);
    
    expect(mockToggle).toHaveBeenCalledWith(1);
  });

  it('nên gọi onDelete khi click nút delete', async () => {
    const user = userEvent.setup();
    const mockDelete = vi.fn();
    render(
      <TodoItem 
        todo={mockTodo} 
        onToggle={vi.fn()} 
        onDelete={mockDelete} 
      />
    );
    
    // Tìm button delete (có thể là text hoặc icon)
    const deleteBtn = screen.getByRole('button', { name: /delete/i });
    await user.click(deleteBtn);
    
    expect(mockDelete).toHaveBeenCalledWith(1);
  });

  it('nên apply class "completed" khi todo completed', () => {
    const completedTodo = { ...mockTodo, completed: true };
    const { container } = render(
      <TodoItem todo={completedTodo} onToggle={vi.fn()} />
    );
    
    const todoItem = container.querySelector('.todo-item');
    expect(todoItem).toHaveClass('completed');
  });
});
```

---

## 🚀 CI/CD Pipeline

### Workflow Tự Động Chạy Khi:
- Push code lên nhánh `main` hoặc `dev/**`
- Tạo Pull Request vào `main` hoặc `dev/**`

### Các Bước Pipeline:
```
1. ✅ Test Backend    → Chạy tất cả test Java
2. ✅ Test Frontend   → Chạy tất cả test React  
3. ✅ Build Backend   → Build Docker image (chỉ trên main)
4. ✅ Build Frontend  → Build Docker image (chỉ trên main)
```

### Status Checks:
- ✅ Tất cả tests phải pass mới được merge
- ✅ Test reports tự động tạo trên GitHub
- ✅ Coverage reports có thể download

---

## 📊 Tình Trạng Hiện Tại

### Backend Tests
- ✅ Cấu trúc cơ bản đã có
- ✅ Maven dependencies đầy đủ
- ⏳ Đang chờ implement test cases (xem Task 1 & 2 từ code review)

### Frontend Tests
- ✅ Vitest đã config
- ✅ Setup file đã tạo
- ⏳ Chỉ có placeholder tests
- ⏳ Đang chờ implement test cases thật

---

## 🎯 Bước Tiếp Theo

### Backend Developer:

1. **Tạo file cấu hình test**:
   ```bash
   # Tạo file src/test/resources/application-test.properties
   # Copy nội dung từ phần "Setup Test Environment" ở trên
   ```

2. **Viết tests theo tasks**:
   - Task 1: Test cho GET và CREATE APIs
   - Task 2: Test cho PATCH và DELETE APIs

3. **Chạy test local**:
   ```bash
   cd backend-java
   mvn clean test
   ```

4. **Commit và push** → CI sẽ tự động chạy

---

### Frontend Developer:

1. **Cài đặt dependencies** (xem phần Setup ở trên)

2. **Bỏ comment trong setup.js**

3. **Xóa placeholder test**

4. **Viết tests theo tasks**:
   - Task 1: Validation & Error Handling
   - Task 2: UI Testing

5. **Chạy test local**:
   ```bash
   cd frontend-react
   npm test
   ```

6. **Commit và push** → CI sẽ tự động chạy

---

## 💡 Tips Quan Trọng

### Chung:
- ✅ Viết test ngay khi code feature (không đợi đến cuối)
- ✅ Test phải chạy nhanh (< 5 phút cho toàn bộ)
- ✅ Mỗi test chỉ test 1 điều duy nhất
- ✅ Đặt tên test rõ ràng: `nên_làmGì_trongTrườngHợpNào`

### Backend:
- ✅ Target coverage: ít nhất 70%
- ✅ Mock external dependencies (API calls, databases khác)
- ✅ Dùng `@Transactional` để giữ DB sạch
- ✅ Test cả happy path VÀ error cases

### Frontend:
- ✅ Test behavior, không test implementation
- ✅ Dùng `screen.getByRole()` thay vì `getByTestId()` khi có thể
- ✅ Mock API calls với `vi.mock()`
- ✅ Test user interactions (click, type, submit)

---

## 📚 Tài Liệu Tham Khảo

- [Vitest Documentation](https://vitest.dev/) - Testing framework cho Vite
- [React Testing Library](https://testing-library.com/react) - Test React components
- [Spring Boot Testing](https://spring.io/guides/gs/testing-web/) - Hướng dẫn Spring
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/) - JUnit 5
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html) - Mock framework
