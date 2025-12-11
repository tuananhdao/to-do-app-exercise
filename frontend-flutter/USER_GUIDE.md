# Hướng dẫn sử dụng Todo App - Flutter Frontend

## Tính năng đã hoàn thiện ✅

### 1. Quản lý Todo

#### Thêm Todo mới
1. Nhấn nút **+** (floating button) ở góc dưới bên phải
2. Nhập tiêu đề todo
3. (Tùy chọn) Nhập các steps, phân cách bằng dấu phẩy
   - Ví dụ: `Mua rau, Nấu cơm, Rửa bát`
4. Nhấn **Save**

#### Sửa Todo
- **Cách 1:** Swipe todo sang phải → Tự động mở dialog sửa
- **Cách 2:** Nhấn vào icon ✏️ trong dialog
- Chỉnh sửa tiêu đề và nhấn **Save**

#### Xóa Todo
- Swipe todo sang trái
- Xác nhận xóa trong dialog
- Todo và tất cả steps con sẽ bị xóa

#### Toggle hoàn thành Todo
- Nhấn checkbox bên trái của todo
- Tất cả steps con sẽ được đánh dấu cùng trạng thái

### 2. Quản lý Task Con (Steps) ✅ MỚI

#### Thêm Task Con
1. Nhấn nút **+** bên cạnh tiêu đề todo
2. Nhập nội dung task con
3. Nhấn **Thêm**
4. Task con sẽ được thêm vào danh sách

#### Sửa Task Con
1. Nhấn icon ✏️ bên cạnh task con
2. Chỉnh sửa nội dung
3. Nhấn **Save**

#### Xóa Task Con ✅ MỚI
1. Nhấn icon 🗑️ (màu đỏ) bên cạnh task con
2. Xác nhận xóa trong dialog
3. Task con sẽ bị xóa

#### Toggle hoàn thành Task Con
- Nhấn checkbox của task con
- Task con sẽ được đánh dấu hoàn thành/chưa hoàn thành
- Nếu tất cả task con hoàn thành → Todo cha tự động hoàn thành

### 3. UI/UX

#### Swipe Actions
- **Swipe phải:** Sửa todo
- **Swipe trái:** Xóa todo

#### Trạng thái Loading
- Hiển thị spinner khi đang tải dữ liệu
- Hiển thị loading khi thực hiện thao tác

#### Error Handling
- Hiển thị thông báo lỗi nếu có vấn đề
- Có nút **Retry** để thử lại

#### Refresh
- Nhấn icon 🔄 trên AppBar để tải lại dữ liệu

## Kiến trúc Technical

### State Management
```
Provider Pattern
├── TodoProvider (ChangeNotifier)
│   ├── Quản lý danh sách todos
│   ├── Loading state
│   └── Error state
```

### Services Layer
```
API Service → Todo Service → Provider → UI
```

### API Endpoints được sử dụng

| Tính năng | Method | Endpoint | Status |
|-----------|--------|----------|--------|
| Lấy danh sách todos | GET | `/api/v1/todos` | ✅ |
| Tạo todo mới | POST | `/api/v1/todos` | ✅ |
| Cập nhật todo | PATCH | `/api/v1/todos/{id}` | ✅ |
| Xóa todo | DELETE | `/api/v1/todos/{id}` | ✅ |
| **Thêm step** | **POST** | `/api/v1/todos/{todoId}/items` | ✅ **MỚI** |
| **Cập nhật step** | **PATCH** | `/api/v1/todos/items/{id}` | ✅ **MỚI** |
| **Xóa step** | **DELETE** | `/api/v1/todos/items/{id}` | ✅ **MỚI** |

## Luồng dữ liệu

### Thêm Step
```
User nhấn + 
  → Dialog nhập nội dung
    → TodoProvider.addStepToTodo()
      → TodoService.addStepToTodo()
        → ApiService.addStepToTodo()
          → POST /api/v1/todos/{todoId}/items
            → Backend xử lý
              → Trả về todo đã cập nhật
                → Provider cập nhật state
                  → UI tự động refresh
```

### Sửa Step
```
User nhấn ✏️
  → Dialog sửa nội dung
    → TodoProvider.updateStepText()
      → TodoService.updateStepTitle()
        → ApiService.updateStep()
          → PATCH /api/v1/todos/items/{id}
            → Backend xử lý
              → Trả về step đã cập nhật
                → Provider fetch lại todos
                  → UI tự động refresh
```

### Xóa Step
```
User nhấn 🗑️
  → Dialog xác nhận
    → TodoProvider.deleteStep()
      → TodoService.deleteStep()
        → ApiService.deleteStep()
          → DELETE /api/v1/todos/items/{id}
            → Backend xử lý
              → Provider fetch lại todos
                → UI tự động refresh
```

## Code Examples

### Thêm Step vào Todo
```dart
// Trong TodoProvider
Future<void> addStepToTodo(int todoId, String stepTitle) async {
  try {
    final updatedTodo = await _todoService.addStepToTodo(todoId, stepTitle);
    _todos = [
      for (final todo in _todos)
        if (todo.id == todoId) updatedTodo else todo,
    ];
    _error = null;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    notifyListeners();
    rethrow;
  }
}
```

### Update Step Title
```dart
// Trong TodoProvider
Future<void> updateStepText(int stepId, String newText) async {
  try {
    await _todoService.updateStepTitle(stepId, newText);
    await fetchTodos(showLoading: false);
    _error = null;
  } catch (e) {
    _error = e.toString();
    notifyListeners();
    rethrow;
  }
}
```

### Delete Step
```dart
// Trong TodoProvider
Future<void> deleteStep(int stepId) async {
  try {
    await _todoService.deleteStep(stepId);
    await fetchTodos(showLoading: false);
    _error = null;
  } catch (e) {
    _error = e.toString();
    notifyListeners();
    rethrow;
  }
}
```

## Troubleshooting

### Step không được thêm/sửa/xóa
1. Kiểm tra backend có đang chạy không
2. Kiểm tra console trong Chrome DevTools (F12)
3. Xem Network tab để check request/response
4. Kiểm tra step có `id` hợp lệ không

### UI không cập nhật sau khi thay đổi
1. Kiểm tra Provider có được notify không
2. Thử nhấn refresh button
3. Restart app

### Lỗi CORS
- Đảm bảo backend đã cấu hình CORS đúng
- Xem file `CORS_FIX_GUIDE.md` để biết thêm chi tiết

## Các cải tiến có thể thêm

- [ ] Drag & drop để sắp xếp steps
- [ ] Đánh dấu ưu tiên (priority) cho todos
- [ ] Filter todos theo trạng thái
- [ ] Search todos
- [ ] Due date cho todos
- [ ] Thông báo (notifications)
- [ ] Dark mode
- [ ] Offline support với local database
