# Deployment Guide

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** installed (>= 1.0)
3. **Docker** installed for local testing
4. **AWS CLI** configured with credentials
5. **EC2 Key Pair** created in your target region

## Step-by-Step Deployment

### 1. Local Development & Testing

```bash
# Clone the repository
git clone <your-repo-url>
cd php-webapp

# Test locally with Docker Compose
docker-compose up -d

# Access the application
open http://localhost:3000

# Stop local environment
docker-compose down
```

### 2. Infrastructure Provisioning

```bash
# Navigate to Terraform directory
cd terraform

# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the infrastructure
terraform apply
```

**Important Outputs:**
- EC2 Public IP
- RDS Endpoint
- ECR Repository URL
- SSH Command

### 3. Manual Deployment (Validation)

```bash
# SSH into EC2 instance
ssh -i your-key.pem ec2-user@<EC2-PUBLIC-IP>

# Check Docker installation
docker --version

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ECR-REPO-URI>

# Build and push initial image (from local machine)
docker build -t php-webapp .
docker tag php-webapp:latest <ECR-REPO-URI>:latest
docker push <ECR-REPO-URI>:latest

# Run container on EC2
docker run -d -p 80:80 --name php-app \
  -e DB_HOST=<RDS-ENDPOINT> \
  -e DB_NAME=webapp_db \
  -e DB_USER=admin \
  -e DB_PASS=<YOUR-PASSWORD> \
  <ECR-REPO-URI>:latest

# Verify application
curl http://localhost
```

### 4. CI/CD Pipeline Setup

#### Option A: AWS CodePipeline (Recommended)

1. **Create GitHub Connection:**
   - Go to AWS CodePipeline Console
   - Create a new connection to GitHub
   - Authorize access to your repository

2. **Create Pipeline:**
   ```bash
   # Use the AWS Console or add to Terraform:
   # - Source: GitHub repository
   # - Build: Use existing CodeBuild project
   # - Deploy: Use existing CodeDeploy application
   ```

#### Option B: Manual Pipeline Creation

```bash
# Create CodePipeline via AWS CLI
aws codepipeline create-pipeline --cli-input-json file://pipeline-config.json
```

### 5. Testing the Complete Setup

1. **Push code changes to GitHub**
2. **Monitor CodePipeline execution**
3. **Verify deployment on EC2**
4. **Test application functionality**

```bash
# Test the application
curl http://<EC2-PUBLIC-IP>

# Check container status
ssh -i your-key.pem ec2-user@<EC2-PUBLIC-IP>
docker ps
docker logs php-app
```

## Troubleshooting

### Common Issues

1. **EC2 Instance not accessible:**
   - Check Security Group rules
   - Verify key pair permissions
   - Ensure instance is in public subnet

2. **Database connection failed:**
   - Verify RDS security group allows EC2 access
   - Check database credentials
   - Ensure RDS is in available state

3. **Docker image pull failed:**
   - Verify ECR permissions
   - Check AWS CLI configuration on EC2
   - Ensure image exists in ECR

4. **CodePipeline failures:**
   - Check IAM roles and permissions
   - Verify GitHub connection
   - Review CodeBuild logs

### Useful Commands

```bash
# Check EC2 instance logs
sudo tail -f /var/log/cloud-init-output.log

# Check CodeDeploy agent status
sudo service codedeploy-agent status

# View Docker logs
docker logs php-app

# Check database connectivity
mysql -h <RDS-ENDPOINT> -u admin -p webapp_db
```

## Security Considerations

1. **Restrict CIDR blocks** in security groups
2. **Use strong database passwords**
3. **Enable RDS encryption**
4. **Regularly update AMIs and containers**
5. **Monitor AWS CloudTrail logs**

## Cost Optimization

1. **Use t3.micro instances** for development
2. **Enable RDS auto-scaling**
3. **Set up CloudWatch alarms**
4. **Use spot instances** for non-production

## Cleanup

```bash
# Destroy infrastructure
cd terraform
terraform destroy

# Clean up ECR images
aws ecr batch-delete-image --repository-name php-webapp --image-ids imageTag=latest
```