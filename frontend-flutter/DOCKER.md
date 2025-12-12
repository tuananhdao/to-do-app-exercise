# Flutter App Docker Setup

## 🐳 Docker Build

### Build Docker Image
```bash
# Build Flutter Web App
docker build -t todo-app-frontend-flutter:latest .

# Build with specific Flutter version
docker build --build-arg FLUTTER_VERSION=3.24.5 -t todo-app-frontend-flutter:latest .
```

### Run Container
```bash
# Run Flutter frontend
docker run -d \
  --name todo-frontend-flutter \
  -p 8081:80 \
  -e BACKEND_URL=http://localhost:8080 \
  todo-app-frontend-flutter:latest

# Access app at: http://localhost:8081
```

## 🚀 CI/CD Pipeline

GitHub Actions workflow tự động:
1. ✅ **Test**: Chạy `flutter test` và analyze code
2. 📊 **Coverage**: Generate test coverage report
3. 🏗️ **Build**: Build Docker image từ Flutter web
4. 📦 **Push**: Push image lên GitHub Container Registry

### Workflow Steps:
```yaml
test-frontend-flutter:
  - Flutter version: 3.24.5
  - Run: flutter pub get
  - Run: flutter analyze
  - Run: flutter test
  - Generate coverage report

build-frontend-flutter:
  - Build multi-stage Docker image
  - Push to ghcr.io/tuananhdao/todo-app-frontend-flutter
```

## 📦 Docker Compose

### Start All Services
```bash
# Start backend + React + Flutter
docker-compose up -d

# View logs
docker-compose logs -f frontend-flutter

# Stop all
docker-compose down
```

### Services:
- **Backend**: http://localhost:8080
- **React Frontend**: http://localhost:5173
- **Flutter Frontend**: http://localhost:8081

## 🏗️ Multi-Stage Build

Dockerfile sử dụng 2 stages:

### Stage 1: Build (Flutter)
- Base image: `ghcr.io/cirruslabs/flutter:stable`
- Install dependencies: `flutter pub get`
- Build web: `flutter build web --release`
- **Note**: Tests run separately in CI/CD pipeline

### Stage 2: Serve (Nginx)
- Base image: `nginx:alpine`
- Copy built files từ stage 1
- Serve trên port 80
- Health check enabled

## 🔧 Nginx Configuration

Custom nginx.conf có:
- ✅ Gzip compression
- ✅ Static asset caching (1 year)
- ✅ SPA routing (redirect to index.html)
- ✅ API proxy to backend
- ✅ Security headers

## 🧪 Testing in Docker

```bash
# Build and test
docker build --target build -t flutter-test .

# Run tests only
docker run --rm flutter-test flutter test
```

## 📊 Health Checks

```yaml
healthcheck:
  test: wget --quiet --tries=1 --spider http://localhost:80
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 30s
```

## 🌐 Environment Variables

- `BACKEND_URL`: Backend API URL (default: http://backend:8080)

## 📝 Notes

- Flutter web được build với `--web-renderer canvaskit` cho hiệu năng tốt nhất
- Image size được tối ưu với multi-stage build (~50MB final image)
- Tests chạy tự động trong CI pipeline trước khi build
- Coverage report được upload lên Codecov
