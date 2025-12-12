# Todo App - Docker Commands Makefile

.PHONY: help build up down logs test clean rebuild

# Default target
help:
	@echo "Todo App - Docker Commands"
	@echo ""
	@echo "Production Commands:"
	@echo "  make up              - Start all services (production)"
	@echo "  make down            - Stop all services"
	@echo "  make logs            - View logs from all services"
	@echo "  make ps              - Show running containers"
	@echo ""
	@echo "Development Commands:"
	@echo "  make dev-up          - Start all services (development)"
	@echo "  make dev-down        - Stop development services"
	@echo "  make dev-build       - Build development images"
	@echo ""
	@echo "Build Commands:"
	@echo "  make build           - Build all Docker images locally"
	@echo "  make build-backend   - Build backend image"
	@echo "  make build-react     - Build React frontend image"
	@echo "  make build-flutter   - Build Flutter frontend image"
	@echo ""
	@echo "Test Commands:"
	@echo "  make test            - Run all tests"
	@echo "  make test-backend    - Run backend tests"
	@echo "  make test-react      - Run React tests"
	@echo "  make test-flutter    - Run Flutter tests"
	@echo ""
	@echo "Maintenance Commands:"
	@echo "  make clean           - Remove all containers and images"
	@echo "  make rebuild         - Clean and rebuild everything"
	@echo "  make prune           - Remove unused Docker resources"

# Production commands
up:
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f

ps:
	docker-compose ps

# Development commands
dev-up:
	docker-compose -f docker-compose.dev.yml up -d

dev-down:
	docker-compose -f docker-compose.dev.yml down

dev-build:
	docker-compose -f docker-compose.dev.yml build

# Build commands
build: build-backend build-react build-flutter

build-backend:
	@echo "Building backend..."
	cd backend-java && docker build -t todo-app-backend:latest .

build-react:
	@echo "Building React frontend..."
	cd frontend-react && docker build -t todo-app-frontend-react:latest .

build-flutter:
	@echo "Building Flutter frontend..."
	cd frontend-flutter && docker build -t todo-app-frontend-flutter:latest .

# Test commands
test: test-backend test-react test-flutter

test-backend:
	@echo "Running backend tests..."
	cd backend-java && ./mvnw test

test-react:
	@echo "Running React tests..."
	cd frontend-react && npm test -- --run

test-flutter:
	@echo "Running Flutter tests..."
	cd frontend-flutter && flutter test

# Maintenance commands
clean:
	docker-compose down -v --rmi all
	docker-compose -f docker-compose.dev.yml down -v --rmi all

rebuild: clean build up

prune:
	docker system prune -af
	docker volume prune -f

# Individual service commands
backend-shell:
	docker exec -it todo-backend bash

react-shell:
	docker exec -it todo-frontend-react sh

flutter-shell:
	docker exec -it todo-frontend-flutter sh

# Health check
health:
	@echo "Checking service health..."
	@curl -f http://localhost:8080/actuator/health || echo "Backend: DOWN"
	@curl -f http://localhost:5173 -s -o /dev/null && echo "React: UP" || echo "React: DOWN"
	@curl -f http://localhost:8081 -s -o /dev/null && echo "Flutter: UP" || echo "Flutter: DOWN"
