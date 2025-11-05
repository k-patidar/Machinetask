# AWS Setup Script for Nearprop2025
# Account ID: 430503858617
# IAM User: Nearprop2025
# Region: us-east-1 (N. Virginia)

Write-Host "=== AWS Setup for Nearprop2025 ===" -ForegroundColor Green
Write-Host "Account ID: 430503858617" -ForegroundColor Cyan
Write-Host "IAM User: Nearprop2025" -ForegroundColor Cyan
Write-Host "Region: us-east-1 (N. Virginia)" -ForegroundColor Cyan

# Check if AWS CLI is installed
Write-Host "`n1. Checking AWS CLI..." -ForegroundColor Yellow
try {
    $awsVersion = aws --version
    Write-Host "✓ AWS CLI found: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ AWS CLI not found. Installing..." -ForegroundColor Red
    Write-Host "Please download and install AWS CLI from: https://aws.amazon.com/cli/" -ForegroundColor Cyan
    exit 1
}

# Configure AWS CLI
Write-Host "`n2. Configuring AWS CLI..." -ForegroundColor Yellow
Write-Host "Setting up AWS CLI for Nearprop2025 account..." -ForegroundColor White

# Set default region and output format
aws configure set region us-east-1
aws configure set output json

Write-Host "`nPlease enter your AWS credentials:" -ForegroundColor Cyan
Write-Host "Run this command and enter your credentials:" -ForegroundColor White
Write-Host "aws configure" -ForegroundColor Yellow
Write-Host ""
Write-Host "When prompted, enter:" -ForegroundColor White
Write-Host "AWS Access Key ID: [Your Nearprop2025 Access Key]" -ForegroundColor Gray
Write-Host "AWS Secret Access Key: [Your Nearprop2025 Secret Key]" -ForegroundColor Gray
Write-Host "Default region name: us-east-1" -ForegroundColor Gray
Write-Host "Default output format: json" -ForegroundColor Gray

Read-Host "`nPress Enter after you've configured AWS CLI with your credentials"

# Verify AWS credentials
Write-Host "`n3. Verifying AWS credentials..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity --output json | ConvertFrom-Json
    
    if ($identity.Account -eq "430503858617") {
        Write-Host "✓ Correct AWS account verified: $($identity.Account)" -ForegroundColor Green
        Write-Host "✓ User: $($identity.Arn)" -ForegroundColor Green
    } else {
        Write-Host "✗ Wrong AWS account. Expected: 430503858617, Got: $($identity.Account)" -ForegroundColor Red
        Write-Host "Please check your AWS credentials" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "✗ Failed to verify AWS credentials" -ForegroundColor Red
    Write-Host "Please run 'aws configure' and enter valid credentials" -ForegroundColor Yellow
    exit 1
}

# Create EC2 Key Pair
Write-Host "`n4. Setting up EC2 Key Pair..." -ForegroundColor Yellow
$keyName = "nearprop-php-webapp-key"

try {
    # Check if key pair exists
    $existingKey = aws ec2 describe-key-pairs --key-names $keyName --region us-east-1 2>$null
    if ($existingKey) {
        Write-Host "✓ Key pair '$keyName' already exists" -ForegroundColor Green
    }
} catch {
    Write-Host "Creating new key pair: $keyName" -ForegroundColor White
    try {
        aws ec2 create-key-pair --key-name $keyName --region us-east-1 --query 'KeyMaterial' --output text | Out-File -FilePath "$keyName.pem" -Encoding ASCII
        Write-Host "✓ Key pair created: $keyName.pem" -ForegroundColor Green
        Write-Host "⚠️  Keep this file secure - needed for SSH access" -ForegroundColor Yellow
        
        # Set proper permissions on Windows
        icacls "$keyName.pem" /inheritance:r /grant:r "$env:USERNAME:R"
    } catch {
        Write-Host "✗ Failed to create key pair" -ForegroundColor Red
        Write-Host "Check IAM permissions for EC2 operations" -ForegroundColor Yellow
    }
}

# Check Terraform
Write-Host "`n5. Checking Terraform..." -ForegroundColor Yellow
try {
    $terraformVersion = terraform --version
    Write-Host "✓ Terraform found: $($terraformVersion[0])" -ForegroundColor Green
} catch {
    Write-Host "✗ Terraform not found" -ForegroundColor Red
    Write-Host "Please install Terraform from: https://www.terraform.io/downloads" -ForegroundColor Cyan
    exit 1
}

# Initialize Terraform
Write-Host "`n6. Initializing Terraform..." -ForegroundColor Yellow
Set-Location terraform

try {
    terraform init
    Write-Host "✓ Terraform initialized" -ForegroundColor Green
} catch {
    Write-Host "✗ Terraform initialization failed" -ForegroundColor Red
    Set-Location ..
    exit 1
}

# Validate Terraform
Write-Host "`n7. Validating Terraform configuration..." -ForegroundColor Yellow
try {
    terraform validate
    Write-Host "✓ Terraform configuration valid" -ForegroundColor Green
} catch {
    Write-Host "✗ Terraform validation failed" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Set-Location ..

Write-Host "`n=== Setup Complete! ===" -ForegroundColor Green
Write-Host "`nYour AWS environment is ready for deployment:" -ForegroundColor White
Write-Host "✓ AWS CLI configured for account 430503858617" -ForegroundColor Gray
Write-Host "✓ EC2 key pair ready for SSH access" -ForegroundColor Gray
Write-Host "✓ Terraform initialized and validated" -ForegroundColor Gray

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Review terraform/terraform.tfvars if needed" -ForegroundColor White
Write-Host "2. Run: .\deploy-nearprop.ps1" -ForegroundColor White
Write-Host "3. Wait for deployment to complete (~10-15 minutes)" -ForegroundColor White