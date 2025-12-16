# Script để chạy backend Spring Boot với CORS enabled

Write-Host "Starting Backend Server with CORS enabled..." -ForegroundColor Green

# Set OPENAI_API_KEY (dùng dummy value nếu không có key thật)
$env:OPENAI_API_KEY = "dummy-key-for-development"

# Navigate to backend directory
Set-Location $PSScriptRoot

# Run Spring Boot application
Write-Host "Backend will start on http://localhost:8080" -ForegroundColor Cyan
Write-Host "CORS is configured to allow all localhost origins" -ForegroundColor Cyan
Write-Host ""

.\mvnw.cmd spring-boot:run
