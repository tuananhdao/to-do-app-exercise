# Test Guide - Toggle Checkbox Features

## Logic đã được cập nhật ✅

### Backend Logic (đã có sẵn)

1. **Toggle Todo:**
   - Khi toggle todo → cập nhật `completed` của todo
   - Nếu `completed = true` → tất cả steps con cũng được set `completed = true`
   - Nếu `completed = false` → steps giữ nguyên trạng thái

2. **Toggle Step:**
   - Khi toggle step → cập nhật `completed` của step
   - Backend tự động kiểm tra: nếu TẤT CẢ steps đều `completed = true` → todo cha cũng `completed = true`
   - Nếu có ít nhất 1 step `completed = false` → todo cha `completed = false`

### Frontend Logic (đã sửa)

#### Trước khi sửa ❌
```dart
// SAI: Gửi giá trị hiện tại thay vì toggle
final updatedTodo = await _todoService.toggleTodo(todoId, currentCompleted);
final updatedStep = await _todoService.toggleStep(stepId, currentStep.completed);
```

#### Sau khi sửa ✅
```dart
// ĐÚNG: Gửi giá trị NGƯỢC LẠI (toggle)
final updatedTodo = await _todoService.toggleTodo(todoId, !currentCompleted);
await _todoService.toggleStep(stepId, !targetStep.completed);
await fetchTodos(showLoading: false); // Đồng bộ lại
```

## Test Cases

### Test 1: Toggle Todo từ chưa hoàn thành → hoàn thành

**Bước test:**
1. Tạo todo mới với 3 steps (tất cả chưa hoàn thành)
2. Click checkbox của todo
3. Quan sát kết quả

**Kết quả mong đợi:**
- ✅ Checkbox todo được tick
- ✅ TẤT CẢ checkboxes của steps con đều được tick
- ✅ Backend lưu `completed = true` cho todo và tất cả steps

**API Call:**
```
PATCH /api/v1/todos/{id}
Body: { "completed": true }
```

### Test 2: Toggle Todo từ hoàn thành → chưa hoàn thành

**Bước test:**
1. Có todo đã hoàn thành (tất cả steps đã tick)
2. Click checkbox của todo để bỏ tick
3. Quan sát kết quả

**Kết quả mong đợi:**
- ✅ Checkbox todo bỏ tick
- ⚠️ Steps giữ nguyên trạng thái (vẫn tick)
- ✅ Backend lưu `completed = false` cho todo

**Lưu ý:** Backend không tự động bỏ tick steps khi bỏ tick todo. Đây là thiết kế của backend.

### Test 3: Toggle Step → Todo tự động hoàn thành

**Bước test:**
1. Tạo todo với 3 steps (tất cả chưa tick)
2. Tick lần lượt step 1, step 2
3. Tick step 3 (step cuối cùng)
4. Quan sát kết quả

**Kết quả mong đợi:**
- ✅ Sau khi tick step 1, step 2: Todo vẫn chưa tick
- ✅ Sau khi tick step 3: Todo TỰ ĐỘNG tick
- ✅ Backend tự động set `completed = true` cho todo cha

**API Call mỗi lần toggle step:**
```
PATCH /api/v1/todos/items/{stepId}
Body: { "completed": true }

Response: Step đã update
Backend tự động update todo cha (không có trong response)
```

### Test 4: Toggle Step → Todo tự động bỏ hoàn thành

**Bước test:**
1. Có todo đã hoàn thành (tất cả steps đã tick)
2. Bỏ tick 1 step bất kỳ
3. Quan sát kết quả

**Kết quả mong đợi:**
- ✅ Step được bỏ tick
- ✅ Todo TỰ ĐỘNG bỏ tick
- ✅ Backend tự động set `completed = false` cho todo cha

### Test 5: Đồng bộ giữa các thiết bị

**Bước test:**
1. Mở app trên 2 tab Chrome khác nhau
2. Toggle checkbox ở tab 1
3. Nhấn refresh (🔄) ở tab 2

**Kết quả mong đợi:**
- ✅ Tab 2 hiển thị đúng trạng thái mới nhất
- ✅ Dữ liệu được đồng bộ từ backend

## Cách chạy test

### 1. Đảm bảo backend đang chạy
```powershell
cd backend-java
.\run-backend.ps1
```

### 2. Chạy Flutter app
```powershell
cd frontend-flutter
flutter run -d chrome
```

### 3. Mở Chrome DevTools
- Nhấn F12
- Vào tab Network
- Filter: XHR
- Observe các API calls khi toggle

### 4. Hot Reload để apply changes
Trong terminal Flutter, nhấn:
- `r` để hot reload
- `R` để hot restart (nếu cần)

## Debug Tips

### Kiểm tra request gửi đi
Trong Chrome DevTools → Network:
```json
// Toggle todo
PATCH http://localhost:8080/api/v1/todos/1
Request Payload: {
  "completed": true  // Phải là giá trị NGƯỢC LẠI với hiện tại
}

// Toggle step
PATCH http://localhost:8080/api/v1/todos/items/1
Request Payload: {
  "completed": true  // Phải là giá trị NGƯỢC LẠI với hiện tại
}
```

### Kiểm tra response
```json
// Response từ toggle todo
{
  "code": 1000,
  "message": "Success",
  "result": {
    "id": 1,
    "title": "Todo title",
    "completed": true,  // Đã thay đổi
    "steps": [
      {
        "id": 1,
        "items": "Step 1",
        "completed": true  // Tất cả steps cũng true
      }
    ]
  }
}
```

### Nếu toggle không hoạt động
1. Check console có error không
2. Check Network tab - request có được gửi không
3. Check request payload có đúng không (phải là !currentValue)
4. Check response có trả về đúng data không
5. Thử hot restart: nhấn `R` trong Flutter terminal

## Known Issues & Solutions

### Issue 1: Checkbox tick nhưng không lưu
**Nguyên nhân:** Request không được gửi đến backend
**Giải pháp:** Check CORS, check backend có chạy không

### Issue 2: Todo không tự động tick khi tick hết steps
**Nguyên nhân:** Flutter không fetch lại data sau khi toggle step
**Giải pháp:** Đã fix - sau khi toggle step, code tự động gọi `fetchTodos()`

### Issue 3: UI không update ngay
**Nguyên nhân:** Provider chưa notify listeners
**Giải pháp:** Đã fix - đảm bảo `notifyListeners()` được gọi

## Kết luận

Sau khi fix, logic toggle đã hoạt động đúng theo thiết kế của backend:
- ✅ Toggle todo → tất cả steps cùng trạng thái (nếu tick todo)
- ✅ Toggle step → todo cha tự động cập nhật
- ✅ Đồng bộ real-time với backend
- ✅ UI update ngay lập tức
