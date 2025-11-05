# Complete Deployment Script for Nearprop2025 AWS Account
# Account: 430503858617 | User: Nearprop2025 | Region: us-east-1

Write-Host "=== Deploying PHP Web Application ===" -ForegroundColor Green
Write-Host "AWS Account: 430503858617 (Nearprop2025)" -ForegroundColor Cyan
Write-Host "Region: us-east-1 (N. Virginia)" -ForegroundColor Cyan
Write-Host "Deployment Time: $(Get-Date)" -ForegroundColor Gray

# Pre-deployment verification
Write-Host "`n🔍 Step 1: Pre-deployment checks..." -ForegroundColor Yellow

# Verify AWS credentials
try {
    $identity = aws sts get-caller-identity --output json | ConvertFrom-Json
    if ($identity.Account -eq "430503858617") {
        Write-Host "✓ AWS account verified: $($identity.Account)" -ForegroundColor Green
        Write-Host "✓ User: $($identity.Arn.Split('/')[-1])" -ForegroundColor Green
    } else {
        Write-Host "✗ Wrong AWS account. Expected: 430503858617" -ForegroundColor Red
        Write-Host "Run setup-aws-nearprop.ps1 first" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "✗ AWS credentials not configured" -ForegroundColor Red
    Write-Host "Run setup-aws-nearprop.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Check Terraform
Set-Location terraform
try {
    terraform --version | Out-Null
    Write-Host "✓ Terraform ready" -ForegroundColor Green
} catch {
    Write-Host "✗ Terraform not available" -ForegroundColor Red
    exit 1
}

# Check configuration file
if (Test-Path "terraform.tfvars") {
    Write-Host "✓ Configuration file found" -ForegroundColor Green
} else {
    Write-Host "✗ terraform.tfvars not found" -ForegroundColor Red
    Write-Host "Run setup-aws-nearprop.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Create deployment plan
Write-Host "`n📋 Step 2: Creating deployment plan..." -ForegroundColor Yellow
Write-Host "Analyzing required AWS resources..." -ForegroundColor Gray

try {
    terraform plan -out=nearprop-deployment.tfplan
    Write-Host "✓ Deployment plan created successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to create deployment plan" -ForegroundColor Red
    Write-Host "Check your AWS permissions and configuration" -ForegroundColor Yellow
    Set-Location ..
    exit 1
}

# Show what will be created
Write-Host "`n📦 Resources to be created:" -ForegroundColor Cyan
Write-Host "• VPC with public/private subnets (Multi-AZ)" -ForegroundColor White
Write-Host "• EC2 instance (t3.micro) with Docker" -ForegroundColor White
Write-Host "• RDS MySQL database (db.t3.micro)" -ForegroundColor White
Write-Host "• ECR repository for Docker images" -ForegroundColor White
Write-Host "• Security groups and IAM roles" -ForegroundColor White
Write-Host "• CodeBuild and CodeDeploy for CI/CD" -ForegroundColor White
Write-Host "• S3 bucket for deployment artifacts" -ForegroundColor White

Write-Host "`n💰 Estimated monthly cost: ~$25-30" -ForegroundColor Yellow

# Confirm deployment
Write-Host "`n⚠️  Ready to deploy infrastructure..." -ForegroundColor Yellow
$confirm = Read-Host "Do you want to proceed? This will create AWS resources. (yes/no)"

if ($confirm.ToLower() -ne "yes") {
    Write-Host "❌ Deployment cancelled by user" -ForegroundColor Yellow
    Set-Location ..
    exit 0
}

# Execute deployment
Write-Host "`n🚀 Step 3: Deploying infrastructure..." -ForegroundColor Yellow
Write-Host "This will take approximately 10-15 minutes..." -ForegroundColor Cyan
Write-Host "☕ Perfect time for a coffee break!" -ForegroundColor Gray

$startTime = Get-Date

try {
    terraform apply nearprop-deployment.tfplan
    $endTime = Get-Date
    $duration = $endTime - $startTime
    Write-Host "✅ Infrastructure deployed successfully!" -ForegroundColor Green
    Write-Host "⏱️  Deployment time: $($duration.Minutes) minutes $($duration.Seconds) seconds" -ForegroundColor Gray
} catch {
    Write-Host "❌ Deployment failed" -ForegroundColor Red
    Write-Host "Check the error messages above for details" -ForegroundColor Yellow
    Set-Location ..
    exit 1
}

# Retrieve and display outputs
Write-Host "`n📊 Step 4: Retrieving deployment information..." -ForegroundColor Yellow

try {
    $outputs = terraform output -json | ConvertFrom-Json
    
    Write-Host "`n🎉 Deployment Complete! Your Resources:" -ForegroundColor Green
    Write-Host "=" * 50 -ForegroundColor Gray
    
    Write-Host "🌐 Application URL: " -NoNewline -ForegroundColor Cyan
    Write-Host "$($outputs.application_url.value)" -ForegroundColor White
    
    Write-Host "🖥️  EC2 Public IP: " -NoNewline -ForegroundColor Cyan
    Write-Host "$($outputs.ec2_public_ip.value)" -ForegroundColor White
    
    Write-Host "🔑 SSH Command: " -NoNewline -ForegroundColor Cyan
    Write-Host "$($outputs.ssh_command.value)" -ForegroundColor White
    
    Write-Host "🗄️  Database Endpoint: " -NoNewline -ForegroundColor Cyan
    Write-Host "$($outputs.rds_endpoint.value)" -ForegroundColor White
    
    Write-Host "📦 ECR Repository: " -NoNewline -ForegroundColor Cyan
    Write-Host "$($outputs.ecr_repository_url.value)" -ForegroundColor White
    
    # Save outputs to file
    $deploymentInfo = @{
        timestamp = Get-Date
        account_id = "430503858617"
        region = "us-east-1"
        outputs = $outputs
    }
    
    $deploymentInfo | ConvertTo-Json -Depth 4 | Out-File -FilePath "../nearprop-deployment-info.json"
    Write-Host "`n💾 Deployment info saved to: nearprop-deployment-info.json" -ForegroundColor Green
    
} catch {
    Write-Host "⚠️  Could not retrieve all outputs. Check manually with:" -ForegroundColor Yellow
    Write-Host "terraform output" -ForegroundColor Gray
}

Set-Location ..

# Post-deployment instructions
Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. ⏳ Wait 2-3 minutes for EC2 to fully initialize" -ForegroundColor White
Write-Host "2. 🌐 Open your application in browser using the URL above" -ForegroundColor White
Write-Host "3. 🔐 SSH to EC2 instance using the command above" -ForegroundColor White
Write-Host "4. 📝 Test the form submission to verify database connectivity" -ForegroundColor White
Write-Host "5. 🔄 Set up GitHub repository for CI/CD (optional)" -ForegroundColor White

Write-Host "`n🔧 Useful Commands:" -ForegroundColor Cyan
Write-Host "• Check application: curl http://<EC2-IP>" -ForegroundColor Gray
Write-Host "• View container logs: docker logs php-app" -ForegroundColor Gray
Write-Host "• Restart container: docker restart php-app" -ForegroundColor Gray

Write-Host "`n🎊 Deployment Complete for Nearprop2025!" -ForegroundColor Green
Write-Host "Your PHP web application is now running on AWS!" -ForegroundColor White