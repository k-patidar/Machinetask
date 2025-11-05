# Manual AWS Setup - Simple Version

Write-Host "Manual AWS Setup for Account 430503858617" -ForegroundColor Green

Write-Host "Step 1: Configure AWS CLI" -ForegroundColor Yellow
Write-Host "Run this command and enter your credentials:" -ForegroundColor White
Write-Host "aws configure" -ForegroundColor Cyan

Write-Host "`nWhen prompted, enter:" -ForegroundColor White
Write-Host "AWS Access Key ID: [Your Access Key]" -ForegroundColor Gray
Write-Host "AWS Secret Access Key: [Your Secret Key]" -ForegroundColor Gray
Write-Host "Default region name: us-east-1" -ForegroundColor Gray
Write-Host "Default output format: json" -ForegroundColor Gray

Read-Host "`nPress Enter after you have run 'aws configure'"

Write-Host "`nStep 2: Testing credentials..." -ForegroundColor Yellow
aws sts get-caller-identity

Write-Host "`nStep 3: If credentials work, run Terraform:" -ForegroundColor Yellow
Write-Host "cd terraform" -ForegroundColor Cyan
Write-Host "terraform plan" -ForegroundColor Cyan