#!/bin/bash

echo "Starting PHP application container..."

# Set variables
AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/php-webapp"

# Login to ECR
echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY

# Pull the latest image
echo "Pulling latest Docker image..."
docker pull $ECR_REPOSITORY:latest

# Load environment variables
if [ -f /home/ec2-user/.env ]; then
    echo "Loading environment variables from .env file..."
    ENV_FILE="/home/ec2-user/.env"
else
    echo "Creating environment file..."
    # Get RDS endpoint from AWS (you might need to adjust this based on your setup)
    DB_HOST=$(aws rds describe-db-instances --query 'DBInstances[?DBName==`webapp_db`].Endpoint.Address' --output text)
    
    cat > /home/ec2-user/.env << EOF
DB_HOST=${DB_HOST}
DB_NAME=webapp_db
DB_USER=admin
DB_PASS=MySecurePassword123!
EOF
    ENV_FILE="/home/ec2-user/.env"
fi

# Start the new container
echo "Starting new container..."
docker run -d \
    --name php-app \
    -p 80:80 \
    --env-file $ENV_FILE \
    --restart unless-stopped \
    $ECR_REPOSITORY:latest

# Check if container started successfully
if docker ps --filter "name=php-app" --format "table {{.Names}}\t{{.Status}}" | grep -q "php-app"; then
    echo "Container started successfully!"
    docker ps --filter "name=php-app"
else
    echo "Failed to start container. Checking logs..."
    docker logs php-app
    exit 1
fi

echo "Start container script completed"