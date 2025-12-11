# To-Do App

A full-stack To-Do List application with web and mobile clients.

## Project Structure

```
├── frontend/   # React web application
├── backend/    # Express REST API
└── flutter/    # Flutter mobile application
```

## Frontend (React)

React-based web client that communicates with the Express backend.

**Features:**
- Display, add, complete, and delete to-do items
- Loading and error states

**Tech Stack:** React, functional components, hooks, Jest + React Testing Library

**Run locally:**
```bash
cd frontend
npm install
npm start
```
Runs on port `3000`. Set `REACT_APP_API_URL` in `.env` for the backend URL.

## Backend (Spring Boot)

REST API for managing to-do items.

**Endpoints:**
| Method | Route | Description |
|--------|-------|-------------|
| GET | `/todos` | Get all to-dos |
| POST | `/todos` | Add a new to-do |
| PATCH | `/todos/:id` | Mark as completed |
| DELETE | `/todos/:id` | Delete a to-do |

**Tech Stack:** Java, Spring Boot, in-memory storage, JUnit for testing

**Run locally:**
```bash
cd backend
./mvnw spring-boot:run
```
Runs on port `4000`.

## Flutter (mobile)

Cross-platform mobile app for Android/iOS.

### Prereqs (Android)
1) Install Flutter (stable) and add to PATH.  
2) Install Android Studio (SDK + Platform Tools).  
3) JDK 17+ (Android Studio bundles one; otherwise set `JAVA_HOME`).  
4) Keep `android/local.properties` untracked (machine-specific).

### One-time setup
```bash
# Point Flutter to your SDK (adjust path)
flutter config --android-sdk "E:\android\sdk"

# Accept Android SDK licenses
flutter doctor --android-licenses
```

Create an emulator (via Android Studio → Device Manager): Pixel 8 (or similar), API 34 Google Play (x86_64). Start it from Device Manager.

### Backend URL
- Default: `lib/config/constants.dart` → `BASE_URL = http://localhost:8080`
- Override per run:  
  `flutter run -d <device_id> --dart-define=BASE_URL=https://your-api`

### Run on emulator/device
```bash
cd frontend-flutter
flutter pub get
flutter devices          # check your device/emulator id
flutter run -d <device_id>
```

### Common fixes
- Gradle/JDK mismatch: use JDK 17+, then `flutter clean`.
- No devices: start an AVD in Android Studio or plug in a phone with USB debugging.
- If builds stall, stop the emulator and retry `flutter run`.

## Docker

Both frontend and backend include Dockerfiles. Use the root `docker-compose.yml` to run the full stack:

```bash
docker-compose up
```

## Development Workflow

- Create a new branch for each feature/fix (reference GitHub Issue in branch name)
- Open a Pull Request linking to the Issue
- Require at least one approval before merging
- CI/CD via GitHub Actions: tests, linting, Docker builds, and image publishing
