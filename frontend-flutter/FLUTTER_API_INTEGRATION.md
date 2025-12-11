# Flutter Frontend - Todo App

Ứng dụng Todo List được xây dựng bằng Flutter, tích hợp với backend Java Spring Boot.

## Cấu trúc dự án

```
lib/
├── config/
│   └── api_config.dart       # Cấu hình API endpoints
├── models/
│   └── todo.dart             # Models cho Todo và TodoStep
├── providers/
│   └── todo_provider.dart    # State management với Provider
├── services/
│   ├── api_service.dart      # HTTP client để gọi REST API
│   └── todo_service.dart     # Business logic layer
├── widgets/
│   └── todo_tile.dart        # Widget hiển thị todo item
├── pages/                     # (reserved for future pages)
└── main.dart                 # Entry point của ứng dụng
```

## Cài đặt và chạy

### 1. Cài đặt dependencies

```bash
flutter pub get
```

### 2. Cấu hình Backend URL

Mở file `lib/config/api_config.dart` và cập nhật `baseUrl` phù hợp với môi trường:

```dart
// Cho Windows/Web
static const String baseUrl = 'http://localhost:8080';

// Cho Android Emulator
static const String baseUrl = 'http://10.0.2.2:8080';

// Cho iOS Simulator
static const String baseUrl = 'http://localhost:8080';

// Cho thiết bị thật (thay bằng IP máy tính)
static const String baseUrl = 'http://192.168.x.x:8080';
```

### 3. Đảm bảo backend đang chạy

Backend Java phải chạy trên port 8080. Kiểm tra bằng cách:

```bash
curl http://localhost:8080/api/v1/todos
```

### 4. Chạy ứng dụng Flutter

#### Chạy trên Chrome (Web)
```bash
flutter run -d chrome
```

#### Chạy trên Windows
```bash
flutter run -d windows
```

#### Chạy trên Android Emulator
```bash
flutter run -d <device-id>
```

## API Endpoints được sử dụng

### Todo Operations
- `GET /api/v1/todos` - Lấy danh sách todos
- `POST /api/v1/todos` - Tạo todo mới
- `PATCH /api/v1/todos/{id}` - Cập nhật todo
- `DELETE /api/v1/todos/{id}` - Xóa todo

### TodoStep Operations
- `POST /api/v1/todos/{todoId}/items` - Thêm step vào todo
- `PATCH /api/v1/todos/items/{id}` - Cập nhật step
- `DELETE /api/v1/todos/items/{id}` - Xóa step

## Tính năng

✅ **Quản lý Todo**
- Xem danh sách todos từ backend
- Thêm todo mới (với hoặc không có steps)
- Sửa title của todo
- Xóa todo (có confirmation)
- Toggle completion status của todo

✅ **Quản lý Steps**
- Toggle completion status của step
- Sửa step title
- Tự động cập nhật status của parent todo

✅ **UI/UX**
- Loading indicator khi fetch data
- Error handling và hiển thị thông báo lỗi
- Pull to refresh (nút refresh trên AppBar)
- Swipe actions cho edit và delete
- Material Design 3

## State Management

Sử dụng **Provider** pattern:
- `TodoProvider` quản lý state toàn bộ todos
- Tự động refresh UI khi data thay đổi
- Error handling tập trung

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  http: ^1.2.0          # HTTP client
  provider: ^6.1.1      # State management
```

## Troubleshooting

### Lỗi kết nối API
1. Kiểm tra backend có đang chạy không
2. Kiểm tra URL trong `api_config.dart` có đúng không
3. Nếu dùng Android Emulator, phải dùng `10.0.2.2` thay vì `localhost`
4. Kiểm tra CORS settings trong backend

### Lỗi build
```bash
flutter clean
flutter pub get
flutter run
```

## Hot Reload

Trong quá trình development, sử dụng:
- `r` - Hot reload (giữ state)
- `R` - Hot restart (reset state)
- `q` - Quit

## Backend Response Format

Backend trả về response format như sau:

```json
{
  "code": 1000,
  "message": "Success",
  "result": {
    "id": 1,
    "title": "Todo title",
    "completed": false,
    "steps": [
      {
        "id": 1,
        "items": "Step 1",
        "completed": false
      }
    ]
  }
}
```

- `code: 1000` = Success
- `code: 404` = Not Found
- `code: 9999` = Error
