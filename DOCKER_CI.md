# 🐳 Docker & CI/CD Guide

## 📦 Docker Setup

### Available Docker Compose Configurations

#### 1. Production (`docker-compose.yml`)
Sử dụng pre-built images từ GitHub Container Registry:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

**Services:**
- **Backend**: http://localhost:8080
- **React Frontend**: http://localhost:5173
- **Flutter Frontend**: http://localhost:8081

#### 2. Development (`docker-compose.dev.yml`)
Build images locally với hot-reload support:

```bash
# Start dev environment
docker-compose -f docker-compose.dev.yml up -d

# Rebuild after code changes
docker-compose -f docker-compose.dev.yml up -d --build

# Stop dev environment
docker-compose -f docker-compose.dev.yml down
```

### Individual Service Docker Commands

#### Backend (Spring Boot)
```bash
cd backend-java

# Build image
docker build -t todo-backend:latest .

# Run container
docker run -d -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  --name todo-backend \
  todo-backend:latest
```

#### Frontend React
```bash
cd frontend-react

# Build image
docker build -t todo-frontend-react:latest .

# Run container
docker run -d -p 5173:5173 \
  --name todo-frontend-react \
  todo-frontend-react:latest
```

#### Frontend Flutter
```bash
cd frontend-flutter

# Build image (includes testing)
docker build -t todo-frontend-flutter:latest .

# Run container
docker run -d -p 8081:80 \
  -e BACKEND_URL=http://localhost:8080 \
  --name todo-frontend-flutter \
  todo-frontend-flutter:latest
```

## 🚀 CI/CD Pipeline

### GitHub Actions Workflow

File: `.github/workflows/docker-build.yml`

#### Pipeline Flow

```
┌─────────────────────────────────────────────────────────┐
│                     Push to main/dev                    │
└────────────────────┬────────────────────────────────────┘
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│  Test Backend   │     │  Test Frontend  │
│                 │     │                 │
│ • Maven tests   │     │ • React tests   │
│ • JUnit reports │     │ • Flutter tests │
└────────┬────────┘     │ • Flutter       │
         │              │   analyze       │
         │              │ • Coverage      │
         │              └────────┬────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│  Build Backend  │     │ Build Frontends │
│                 │     │                 │
│ • Docker build  │     │ • React image   │
│ • Push to GHCR  │     │ • Flutter image │
│ • Multi-arch    │     │ • Push to GHCR  │
└─────────────────┘     └─────────────────┘
```

#### Jobs Overview

##### 1. **test-backend**
- Runs on: `ubuntu-latest`
- Java 17 with Maven
- Executes: `mvn clean test`
- Generates JUnit reports

##### 2. **test-frontend-react**
- Runs on: `ubuntu-latest`
- Node.js 20
- Executes: `npm test`
- Conditional (if Vitest installed)

##### 3. **test-frontend-flutter**
- Runs on: `ubuntu-latest`
- Flutter 3.24.5 stable
- Steps:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`
  - `flutter test --coverage`
- Uploads coverage to Codecov

##### 4. **build-backend**
- Depends on: `test-backend`
- Builds multi-arch Docker image (amd64, arm64)
- Pushes to: `ghcr.io/tuananhdao/todo-app-backend:latest`

##### 5. **build-frontend-react**
- Depends on: `test-frontend-react`
- Builds React Docker image
- Pushes to: `ghcr.io/tuananhdao/todo-app-frontend-react:latest`

##### 6. **build-frontend-flutter**
- Depends on: `test-frontend-flutter`
- Builds Flutter web Docker image
- Includes tests in build stage
- Pushes to: `ghcr.io/tuananhdao/todo-app-frontend-flutter:latest`

### Trigger Events

```yaml
on:
  push:
    branches: [ main, 'dev/**' ]
  pull_request:
    branches: [ main, 'dev/**' ]
```

### Environment Variables

```yaml
REGISTRY: ghcr.io
IMAGE_PREFIX: tuananhdao
```

## 📊 Testing in CI

### Backend Tests
```bash
# Maven Surefire Plugin
mvn clean test

# Reports: backend-java/target/surefire-reports/*.xml
```

### React Tests
```bash
# Vitest
npm test -- --run

# Conditional based on dependencies
```

### Flutter Tests
```bash
# Unit & Widget Tests
flutter test

# With Coverage
flutter test --coverage

# Code Analysis
flutter analyze
```

## 🏗️ Docker Build Stages

### Flutter Multi-Stage Build

```dockerfile
# Stage 1: Build
FROM flutter:stable AS build
- Install dependencies
- Run tests
- Build web app

# Stage 2: Serve
FROM nginx:alpine
- Copy built files
- Serve on port 80
```

Benefits:
- ✅ Tests run during build
- ✅ Smaller final image (~50MB)
- ✅ Production-ready Nginx config

## 🔐 GitHub Container Registry

### Pull Images

```bash
# Login (if private)
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Pull backend
docker pull ghcr.io/tuananhdao/todo-app-backend:latest

# Pull React frontend
docker pull ghcr.io/tuananhdao/todo-app-frontend-react:latest

# Pull Flutter frontend
docker pull ghcr.io/tuananhdao/todo-app-frontend-flutter:latest
```

### Image Tags

- `latest`: Latest from main branch
- `sha-<commit>`: Specific commit
- `dev-<branch>`: Development branch

## 🔍 Health Checks

All services include health checks:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

## 📝 Local Testing Workflow

### 1. Test Locally Before Push
```bash
# Backend
cd backend-java
./mvnw test

# React
cd frontend-react
npm test

# Flutter
cd frontend-flutter
flutter test
```

### 2. Build Docker Images
```bash
# Build all services
docker-compose -f docker-compose.dev.yml build

# Test individual service
docker build -t test ./frontend-flutter
docker run --rm test flutter test
```

### 3. Run Integration Tests
```bash
# Start all services
docker-compose up -d

# Check health
docker ps
docker-compose logs

# Test endpoints
curl http://localhost:8080/api/v1/todos
curl http://localhost:5173
curl http://localhost:8081
```

## 🐛 Troubleshooting

### Build Failures

#### Backend
```bash
# Clear Maven cache
./mvnw dependency:purge-local-repository

# Rebuild
docker build --no-cache -t todo-backend .
```

#### Flutter
```bash
# Clean Flutter
flutter clean
flutter pub get

# Rebuild Docker
docker build --no-cache -t todo-flutter .
```

### CI/CD Issues

#### Tests Failing
- Check test reports in Actions artifacts
- Run tests locally with same environment
- Verify dependencies are up to date

#### Docker Push Failing
- Verify GITHUB_TOKEN permissions
- Check if branch is `main`
- Ensure GHCR is enabled

## 📚 Additional Resources

- [Backend Docker Setup](backend-java/README.md)
- [React Docker Setup](frontend-react/README.md)
- [Flutter Docker Setup](frontend-flutter/DOCKER.md)
- [Flutter Tests](frontend-flutter/test/README.md)
