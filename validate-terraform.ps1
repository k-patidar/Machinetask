# Terraform Validation Script

Write-Host "=== Terraform Infrastructure Validation ===" -ForegroundColor Green

# Check if Terraform is installed
Write-Host "`nChecking Terraform installation..." -ForegroundColor Yellow
try {
    $terraformVersion = terraform version
    Write-Host "✓ Terraform found: $($terraformVersion[0])" -ForegroundColor Green
} catch {
    Write-Host "✗ Terraform not found. Please install Terraform." -ForegroundColor Red
    exit 1
}

# Check if AWS CLI is installed
Write-Host "`nChecking AWS CLI installation..." -ForegroundColor Yellow
try {
    $awsVersion = aws --version
    Write-Host "✓ AWS CLI found: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ AWS CLI not found. Please install AWS CLI." -ForegroundColor Red
    exit 1
}

# Check AWS credentials
Write-Host "`nChecking AWS credentials..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity --output json | ConvertFrom-Json
    Write-Host "✓ AWS credentials configured for account: $($identity.Account)" -ForegroundColor Green
} catch {
    Write-Host "✗ AWS credentials not configured. Run 'aws configure'" -ForegroundColor Red
    exit 1
}

# Navigate to terraform directory
Set-Location terraform

# Check if terraform.tfvars exists
Write-Host "`nChecking Terraform configuration..." -ForegroundColor Yellow
if (Test-Path "terraform.tfvars") {
    Write-Host "✓ terraform.tfvars found" -ForegroundColor Green
} else {
    Write-Host "✗ terraform.tfvars not found. Copy from terraform.tfvars.example" -ForegroundColor Red
    Write-Host "Run: Copy-Item terraform.tfvars.example terraform.tfvars" -ForegroundColor Cyan
    exit 1
}

# Initialize Terraform
Write-Host "`nInitializing Terraform..." -ForegroundColor Yellow
try {
    terraform init
    Write-Host "✓ Terraform initialized successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Terraform initialization failed" -ForegroundColor Red
    exit 1
}

# Validate Terraform configuration
Write-Host "`nValidating Terraform configuration..." -ForegroundColor Yellow
try {
    terraform validate
    Write-Host "✓ Terraform configuration is valid" -ForegroundColor Green
} catch {
    Write-Host "✗ Terraform configuration validation failed" -ForegroundColor Red
    exit 1
}

# Plan Terraform deployment
Write-Host "`nCreating Terraform plan..." -ForegroundColor Yellow
try {
    terraform plan -out=tfplan
    Write-Host "✓ Terraform plan created successfully" -ForegroundColor Green
    Write-Host "✓ Review the plan above and run 'terraform apply tfplan' to deploy" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Terraform plan failed" -ForegroundColor Red
    exit 1
}

Set-Location ..

Write-Host "`n=== Validation Complete ===" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review the Terraform plan" -ForegroundColor White
Write-Host "2. Run: cd terraform && terraform apply tfplan" -ForegroundColor White
Write-Host "3. Note the outputs (EC2 IP, RDS endpoint, etc.)" -ForegroundColor White