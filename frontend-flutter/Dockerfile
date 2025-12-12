# Stage 1: Build Flutter Web App
# Use Flutter 3.24.1 to match local development environment
FROM ghcr.io/cirruslabs/flutter:3.24.1 AS build

WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build web app with release mode (tests run separately in CI)
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built web files
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=30s \
  CMD wget --quiet --tries=1 --spider http://localhost:80 || exit 1

CMD ["nginx", "-g", "daemon off;"]
