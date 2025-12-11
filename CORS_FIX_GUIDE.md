# Giải quyết lỗi CORS khi chạy Flutter Web với Backend

## Vấn đề

Khi chạy Flutter app trên web (Chrome), bạn có thể gặp lỗi:

```
Exception: Error fetching todos: ClientException: Failed to fetch, 
uri=http://localhost:8080/api/v1/todos
```

## Nguyên nhân

Đây là lỗi **CORS (Cross-Origin Resource Sharing)**. Flutter web chạy trên một port (ví dụ: `localhost:52000`), trong khi backend chạy trên `localhost:8080`. Trình duyệt sẽ chặn các request cross-origin nếu backend không cho phép.

## Giải pháp đã áp dụng

### 1. Cập nhật CORS Configuration

File `backend-java/src/main/java/com/example/backend/config/CorsConfig.java` đã được cập nhật:

```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns(
                        "http://localhost:*",      // Cho phép tất cả localhost ports
                        "http://127.0.0.1:*"       // Cũng cho phép 127.0.0.1
                )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }
}
```

**Thay đổi chính:**
- Dùng `allowedOriginPatterns()` thay vì `allowedOrigins()` để cho phép wildcard `*`
- Cho phép tất cả ports trên localhost (`localhost:*`)
- Thêm `maxAge(3600)` để cache preflight requests

### 2. Restart Backend

Sau khi thay đổi CORS config, **BẮT BUỘC phải restart backend**:

**Cách 1: Dùng script PowerShell (khuyến nghị)**
```powershell
cd backend-java
.\run-backend.ps1
```

**Cách 2: Manual**
```powershell
cd backend-java
$env:OPENAI_API_KEY="dummy-key"
.\mvnw.cmd spring-boot:run
```

### 3. Kiểm tra CORS hoạt động

Test bằng curl (hoặc PowerShell):

```powershell
# Test request với Origin header
curl http://localhost:8080/api/v1/todos `
  -H "Origin: http://localhost:50000" `
  -v 2>&1 | Select-String "Access-Control"
```

Kết quả mong đợi sẽ có header:
```
Access-Control-Allow-Origin: http://localhost:50000
Access-Control-Allow-Credentials: true
```

## Troubleshooting

### Backend không khởi động được

**Lỗi: Port 8080 already in use**

Giải pháp:
```powershell
# Tìm process đang dùng port 8080
netstat -ano | findstr :8080

# Kill process (thay PID bằng số thực tế)
taskkill /F /PID <PID>
```

**Lỗi: OPENAI_API_KEY environment variable is not set**

Giải pháp:
```powershell
# Set environment variable trước khi chạy
$env:OPENAI_API_KEY="dummy-key-for-development"
.\mvnw.cmd spring-boot:run
```

Hoặc tạo file `.env` trong thư mục `backend-java`:
```
OPENAI_API_KEY=your-key-here
```

### Flutter vẫn không kết nối được

1. **Kiểm tra backend đang chạy:**
   ```powershell
   curl http://localhost:8080/api/v1/todos
   ```

2. **Kiểm tra Flutter đang dùng đúng URL:**
   - Mở `frontend-flutter/lib/config/api_config.dart`
   - Đảm bảo `baseUrl = 'http://localhost:8080'`

3. **Clear browser cache và restart Flutter:**
   ```bash
   # Stop Flutter app (nhấn 'q' trong terminal)
   # Sau đó chạy lại
   flutter run -d chrome
   ```

4. **Xem console trong Chrome DevTools:**
   - Mở DevTools (F12)
   - Vào tab Console
   - Vào tab Network để xem request/response

## Các port thường dùng

- **Backend Java:** `8080`
- **Frontend React:** `3000` hoặc `5173` (Vite)
- **Frontend Flutter Web:** Port ngẫu nhiên (thường `50000-60000`)

## Lưu ý quan trọng

⚠️ **Development vs Production:**

Config CORS hiện tại (`localhost:*`) chỉ phù hợp cho **development**. 

Khi deploy production, cần:
1. Chỉ định cụ thể domain được phép
2. Không dùng wildcard `*`
3. Cấu hình HTTPS

**Production config ví dụ:**
```java
.allowedOrigins(
    "https://your-frontend-domain.com",
    "https://www.your-frontend-domain.com"
)
```

## Tài liệu tham khảo

- [Spring CORS Documentation](https://docs.spring.io/spring-framework/reference/web/webmvc-cors.html)
- [MDN CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Flutter Web CORS](https://docs.flutter.dev/platform-integration/web/building#cors-policy-issues)
