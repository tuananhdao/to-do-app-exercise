# Test PATCH API for Todo

Write-Host "`n=== TEST PATCH /api/v1/todos/{id} ===" -ForegroundColor Cyan

# Helper: capture response body on error (works on Windows PowerShell 5.1)
function Invoke-WithBodyOnError {
    param(
        [Parameter(Mandatory)] [string] $Uri,
        [Parameter(Mandatory)] [string] $Method,
        [Parameter(Mandatory)] [string] $Body,
        [Parameter(Mandatory)] [string] $ContentType
    )
    try {
        return Invoke-WebRequest -Uri $Uri -Method $Method -Body $Body -ContentType $ContentType -UseBasicParsing
    } catch {
        $resp = $_.Exception.Response
        $stream = $resp.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $text = $reader.ReadToEnd()
        return @{ StatusCode = [int]$resp.StatusCode; Content = $text }
    }
}

# Test Case 1: Update title only
Write-Host "`n[Test 1] Update title of Todo ID 1" -ForegroundColor Yellow
$body1 = @{title="Updated Title from Script"} | ConvertTo-Json
$response1 = Invoke-RestMethod -Uri "http://localhost:8081/api/v1/todos/1" -Method PATCH -Body $body1 -ContentType "application/json"
Write-Host "Response:" -ForegroundColor Green
$response1 | ConvertTo-Json -Depth 5

# Test Case 2: Mark completed = true
Write-Host "`n[Test 2] Mark Todo ID 1 as completed (all steps should also be completed)" -ForegroundColor Yellow
$body2 = @{completed=$true} | ConvertTo-Json
$response2 = Invoke-RestMethod -Uri "http://localhost:8081/api/v1/todos/1" -Method PATCH -Body $body2 -ContentType "application/json"
Write-Host "Response:" -ForegroundColor Green
$response2 | ConvertTo-Json -Depth 5

# Test Case 3: Todo not found (should return 404)
Write-Host "`n[Test 3] Update non-existent Todo ID 999 (should return 404)" -ForegroundColor Yellow
$body3 = @{title="Test"} | ConvertTo-Json
$resp404 = Invoke-WithBodyOnError -Uri "http://localhost:8081/api/v1/todos/999" -Method PATCH -Body $body3 -ContentType "application/json"
if ($resp404.StatusCode -eq 404) {
    Write-Host "Status Code: 404" -ForegroundColor Green
    Write-Host "Body:" -ForegroundColor Green
    $resp404.Content
    Write-Host "Expected 404 error - Test PASSED!" -ForegroundColor Green
} else {
    Write-Host "Unexpected status: $($resp404.StatusCode)" -ForegroundColor Red
    Write-Host $resp404.Content
}

Write-Host "`n=== ALL TESTS COMPLETED ===" -ForegroundColor Cyan
