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

## Flutter

Cross-platform mobile application for iOS and Android.

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
