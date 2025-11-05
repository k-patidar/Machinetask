# Create Clean AWS Credentials File

Write-Host "🔧 Creating Clean AWS Credentials" -ForegroundColor Yellow

# Get user input
Write-Host "`nEnter your AWS credentials for account 430503858617:" -ForegroundColor Cyan
$accessKey = Read-Host "AWS Access Key ID (starts with AKIA)"
$secretKey = Read-Host "AWS Secret Access Key"

# Validate format
if (-not $accessKey.StartsWith("AKIA")) {
    Write-Host "❌ Access Key should start with 'AKIA'" -ForegroundColor Red
    exit 1
}

if ($secretKey.Length -lt 20) {
    Write-Host "❌ Secret Key seems too short" -ForegroundColor Red
    exit 1
}

# Create AWS directory
$awsDir = "$env:USERPROFILE\.aws"
if (!(Test-Path $awsDir)) {
    New-Item -ItemType Directory -Path $awsDir -Force | Out-Null
}

# Create credentials file with exact format
$credentialsPath = "$awsDir\credentials"
@"
[default]
aws_access_key_id = $accessKey
aws_secret_access_key = $secretKey
"@ | Out-File -FilePath $credentialsPath -Encoding UTF8

# Create config file
$configPath = "$awsDir\config"
@"
[default]
region = us-east-1
output = json
"@ | Out-File -FilePath $configPath -Encoding UTF8

Write-Host "✓ Credentials file created" -ForegroundColor Green

# Test immediately
Write-Host "`nTesting credentials..." -ForegroundColor Yellow
try {
    $result = aws sts get-caller-identity 2>&1
    if ($LASTEXITCODE -eq 0) {
        $identity = $result | ConvertFrom-Json
        if ($identity.Account -eq "430503858617") {
            Write-Host "✅ SUCCESS! Credentials working" -ForegroundColor Green
            Write-Host "Account: $($identity.Account)" -ForegroundColor White
            Write-Host "User: $($identity.Arn.Split('/')[-1])" -ForegroundColor White
        } else {
            Write-Host "❌ Wrong account: $($identity.Account)" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Credential test failed: $result" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error testing credentials: $($_.Exception.Message)" -ForegroundColor Red
}