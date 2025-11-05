# Simple AWS Credentials Fix Script

Write-Host "Fixing AWS Credentials for Account 430503858617" -ForegroundColor Yellow

# Clear existing credentials
Write-Host "Clearing existing AWS configuration..." -ForegroundColor Cyan
$awsDir = "$env:USERPROFILE\.aws"

if (Test-Path $awsDir) {
    Remove-Item -Path "$awsDir\credentials" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$awsDir\config" -Force -ErrorAction SilentlyContinue
    Write-Host "Cleared existing configuration" -ForegroundColor Green
}

# Create AWS directory
if (!(Test-Path $awsDir)) {
    New-Item -ItemType Directory -Path $awsDir -Force | Out-Null
}

# Get credentials from user
Write-Host "Please enter your AWS credentials:" -ForegroundColor Cyan
Write-Host "Account: 430503858617 (Nearprop2025)" -ForegroundColor Gray

$accessKey = Read-Host "AWS Access Key ID"
$secretKey = Read-Host "AWS Secret Access Key"

# Validate input
if ([string]::IsNullOrWhiteSpace($accessKey) -or [string]::IsNullOrWhiteSpace($secretKey)) {
    Write-Host "Invalid credentials provided" -ForegroundColor Red
    exit 1
}

# Create credentials file
Write-Host "Creating AWS credentials file..." -ForegroundColor Cyan

$credentialsPath = "$awsDir\credentials"
$configPath = "$awsDir\config"

# Write credentials file
"[default]" | Out-File -FilePath $credentialsPath -Encoding ASCII
"aws_access_key_id = $accessKey" | Out-File -FilePath $credentialsPath -Append -Encoding ASCII
"aws_secret_access_key = $secretKey" | Out-File -FilePath $credentialsPath -Append -Encoding ASCII

# Write config file
"[default]" | Out-File -FilePath $configPath -Encoding ASCII
"region = us-east-1" | Out-File -FilePath $configPath -Append -Encoding ASCII
"output = json" | Out-File -FilePath $configPath -Append -Encoding ASCII

Write-Host "AWS configuration files created" -ForegroundColor Green

# Test credentials
Write-Host "Testing AWS credentials..." -ForegroundColor Cyan

try {
    $result = aws sts get-caller-identity --output json
    if ($LASTEXITCODE -eq 0) {
        $identity = $result | ConvertFrom-Json
        if ($identity.Account -eq "430503858617") {
            Write-Host "SUCCESS! Credentials verified" -ForegroundColor Green
            Write-Host "Account: $($identity.Account)" -ForegroundColor White
            Write-Host "User: $($identity.Arn)" -ForegroundColor White
        } else {
            Write-Host "Wrong account. Expected: 430503858617, Got: $($identity.Account)" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Credential verification failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error testing credentials: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "AWS credentials fixed successfully!" -ForegroundColor Green
Write-Host "You can now run Terraform commands." -ForegroundColor White