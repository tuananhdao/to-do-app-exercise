# Dockerfile for React Todo App Frontend

# Build stage
FROM node:20-alpine AS build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the app
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Install serve to run the production build
RUN npm install -g serve

# Copy built files from build stage
COPY --from=build /app/dist ./dist

# Expose port 5173
EXPOSE 5173

# Start the app
CMD ["serve", "-s", "dist", "-l", "5173"]
