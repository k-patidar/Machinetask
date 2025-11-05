# Quick Start Guide for Nearprop2025 AWS Deployment
# Account: 430503858617 | Region: us-east-1

Write-Host "🚀 Quick Start: PHP Web App on AWS" -ForegroundColor Green
Write-Host "Account: 430503858617 (Nearprop2025)" -ForegroundColor Cyan
Write-Host "Region: us-east-1 (N. Virginia)" -ForegroundColor Cyan

Write-Host "`n📋 Prerequisites Check:" -ForegroundColor Yellow

# Check if required tools are installed
$prerequisites = @()

# Check AWS CLI
try {
    aws --version | Out-Null
    Write-Host "✓ AWS CLI installed" -ForegroundColor Green
} catch {
    Write-Host "✗ AWS CLI not found" -ForegroundColor Red
    $prerequisites += "AWS CLI"
}

# Check Terraform
try {
    terraform --version | Out-Null
    Write-Host "✓ Terraform installed" -ForegroundColor Green
} catch {
    Write-Host "✗ Terraform not found" -ForegroundColor Red
    $prerequisites += "Terraform"
}

# Check Docker
try {
    docker --version | Out-Null
    Write-Host "✓ Docker installed" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker not found" -ForegroundColor Red
    $prerequisites += "Docker"
}

if ($prerequisites.Count -gt 0) {
    Write-Host "`n❌ Missing prerequisites:" -ForegroundColor Red
    foreach ($tool in $prerequisites) {
        Write-Host "   • $tool" -ForegroundColor White
    }
    Write-Host "`nPlease install missing tools and run this script again." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n🎯 Deployment Options:" -ForegroundColor Cyan
Write-Host "1. 🧪 Test locally first (recommended)" -ForegroundColor White
Write-Host "2. ⚙️  Setup AWS and deploy to cloud" -ForegroundColor White
Write-Host "3. 🚀 Full deployment (if already configured)" -ForegroundColor White

$choice = Read-Host "`nSelect option (1, 2, or 3)"

switch ($choice) {
    "1" {
        Write-Host "`n🧪 Testing locally..." -ForegroundColor Yellow
        if (Test-Path "test-local.ps1") {
            .\test-local.ps1
        } else {
            Write-Host "Starting local test with Docker Compose..." -ForegroundColor White
            docker-compose up -d
            Start-Sleep -Seconds 10
            Write-Host "✓ Application started at http://localhost:3000" -ForegroundColor Green
        }
    }
    
    "2" {
        Write-Host "`n⚙️  Setting up AWS environment..." -ForegroundColor Yellow
        if (Test-Path "setup-aws-nearprop.ps1") {
            .\setup-aws-nearprop.ps1
        } else {
            Write-Host "❌ Setup script not found" -ForegroundColor Red
            exit 1
        }
    }
    
    "3" {
        Write-Host "`n🚀 Starting full deployment..." -ForegroundColor Yellow
        if (Test-Path "deploy-nearprop.ps1") {
            .\deploy-nearprop.ps1
        } else {
            Write-Host "❌ Deployment script not found" -ForegroundColor Red
            exit 1
        }
    }
    
    default {
        Write-Host "❌ Invalid option selected" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n📚 Additional Resources:" -ForegroundColor Cyan
Write-Host "• README.md - Complete project documentation" -ForegroundColor Gray
Write-Host "• DEPLOYMENT.md - Detailed deployment guide" -ForegroundColor Gray
Write-Host "• ARCHITECTURE.md - System architecture details" -ForegroundColor Gray