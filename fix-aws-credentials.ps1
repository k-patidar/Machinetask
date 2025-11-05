# Fix AWS Credentials Script for Nearprop2025

Write-Host "🔧 Fixing AWS Credentials for Account 430503858617" -ForegroundColor Yellow

# Step 1: Clear existing credentials
Write-Host "`n1. Clearing existing AWS configuration..." -ForegroundColor Cyan
$awsDir = "$env:USERPROFILE\.aws"
if (Test-Path $awsDir) {
    Remove-Item -Path "$awsDir\credentials" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$awsDir\config" -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Cleared existing configuration" -ForegroundColor Green
}

# Step 2: Create AWS directory
if (!(Test-Path $awsDir)) {
    New-Item -ItemType Directory -Path $awsDir -Force | Out-Null
}

# Step 3: Get credentials from user
Write-Host "`n2. Please enter your AWS credentials:" -ForegroundColor Cyan
Write-Host "Account: 430503858617 (Nearprop2025)" -ForegroundColor Gray

$accessKey = Read-Host "AWS Access Key ID"
$secretKey = Read-Host "AWS Secret Access Key"

# Step 4: Validate input
if ([string]::IsNullOrWhiteSpace($accessKey) -or [string]::IsNullOrWhiteSpace($secretKey)) {
    Write-Host "❌ Invalid credentials provided" -ForegroundColor Red
    exit 1
}

# Step 5: Create credentials file
Write-Host "`n3. Creating AWS credentials file..." -ForegroundColor Cyan
$credentialsContent = @"
[default]
aws_access_key_id = $accessKey
aws_secret_access_key = $secretKey
"@

$credentialsContent | Out-File -FilePath "$awsDir\credentials" -Encoding ASCII

# Step 6: Create config file
$configContent = @"
[default]
region = us-east-1
output = json
"@

$configContent | Out-File -FilePath "$awsDir\config" -Encoding ASCII

Write-Host "✓ AWS configuration files created" -ForegroundColor Green

# Step 7: Test credentials
Write-Host "`n4. Testing AWS credentials..." -ForegroundColor Cyan
try {
    $identity = aws sts get-caller-identity --output json | ConvertFrom-Json
    
    if ($identity.Account -eq "430503858617") {
        Write-Host "✅ SUCCESS! Credentials verified" -ForegroundColor Green
        Write-Host "Account: $($identity.Account)" -ForegroundColor White
        Write-Host "User: $($identity.Arn)" -ForegroundColor White
    } else {
        Write-Host "❌ Wrong account. Expected: 430503858617, Got: $($identity.Account)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Credential verification failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Gray
    exit 1
}

Write-Host "`n🎉 AWS credentials fixed successfully!" -ForegroundColor Green
Write-Host "You can now run Terraform commands." -ForegroundColor White