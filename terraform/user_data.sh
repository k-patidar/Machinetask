#!/bin/bash

# Update system
yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install CodeDeploy agent
yum install -y ruby wget
cd /home/ec2-user
wget https://aws-codedeploy-${aws_region}.s3.${aws_region}.amazonaws.com/latest/install
chmod +x ./install
./install auto

# Configure AWS CLI region
aws configure set region ${aws_region}

# Login to ECR
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_repository_uri}

# Create environment file for Docker
cat > /home/ec2-user/.env << EOF
DB_HOST=${db_host}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASS=${db_pass}
EOF

# Create initial deployment script
cat > /home/ec2-user/deploy.sh << 'EOF'
#!/bin/bash

# Stop existing container
docker stop php-app 2>/dev/null || true
docker rm php-app 2>/dev/null || true

# Pull latest image
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_repository_uri}
docker pull ${ecr_repository_uri}:latest

# Run new container
docker run -d \
  --name php-app \
  -p 80:80 \
  --env-file /home/ec2-user/.env \
  ${ecr_repository_uri}:latest

echo "Deployment completed at $(date)"
EOF

chmod +x /home/ec2-user/deploy.sh
chown ec2-user:ec2-user /home/ec2-user/deploy.sh
chown ec2-user:ec2-user /home/ec2-user/.env

# Initial deployment (if image exists)
su - ec2-user -c "/home/ec2-user/deploy.sh" || echo "Initial deployment skipped - image not available yet"