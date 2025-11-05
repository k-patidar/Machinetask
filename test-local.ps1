# Local Testing Script for PHP Web Application

Write-Host "=== PHP Web Application Local Test ===" -ForegroundColor Green

# Check if Docker is installed
Write-Host "`nChecking Docker installation..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✓ Docker found: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker not found. Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check if Docker is running
Write-Host "`nChecking Docker daemon..." -ForegroundColor Yellow
try {
    docker info | Out-Null
    Write-Host "✓ Docker daemon is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker daemon is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Build the Docker image
Write-Host "`nBuilding Docker image..." -ForegroundColor Yellow
try {
    docker build -t php-webapp:test .
    Write-Host "✓ Docker image built successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to build Docker image" -ForegroundColor Red
    exit 1
}

# Start the application with docker-compose
Write-Host "`nStarting application with docker-compose..." -ForegroundColor Yellow
try {
    docker-compose up -d
    Start-Sleep -Seconds 10
    Write-Host "✓ Application started" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to start application" -ForegroundColor Red
    exit 1
}

# Test the application
Write-Host "`nTesting application..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Application is responding (HTTP 200)" -ForegroundColor Green
        Write-Host "✓ Application available at: http://localhost:3000" -ForegroundColor Cyan
    } else {
        Write-Host "✗ Application returned status code: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Failed to connect to application: $($_.Exception.Message)" -ForegroundColor Red
}

# Show running containers
Write-Host "`nRunning containers:" -ForegroundColor Yellow
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host "`n=== Test Complete ===" -ForegroundColor Green
Write-Host "To stop the application, run: docker-compose down" -ForegroundColor Cyan