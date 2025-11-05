# Dockerized PHP Web Application on AWS

A complete infrastructure-as-code solution for deploying a PHP web application with MySQL database on AWS using Docker, Terraform, and CI/CD automation.

## 🚀 Features

- **Modern PHP Application**: Clean, responsive web interface with MySQL integration
- **Infrastructure as Code**: Complete AWS infrastructure provisioned via Terraform
- **Containerization**: Docker-based deployment with php:8.2-apache
- **CI/CD Automation**: AWS CodePipeline with GitHub integration
- **Security Best Practices**: VPC isolation, security groups, IAM roles
- **Scalable Architecture**: Ready for production enhancements

## 🏗️ Architecture Overview

- **Application**: PHP 8.2 web app with form submission to MySQL database
- **Infrastructure**: AWS EC2 + RDS + ECR provisioned via Terraform
- **CI/CD**: AWS CodePipeline → CodeBuild → CodeDeploy automation
- **Containerization**: Docker with official php:8.2-apache base image
- **Networking**: VPC with public/private subnets, security groups
- **Database**: RDS MySQL 8.0 in private subnet

## Project Structure

```
├── app/                    # PHP application code
│   ├── index.php          # Main form page
│   ├── db.php             # Database connection
│   └── config.php         # Configuration file
├── terraform/             # Infrastructure as Code
│   ├── provider.tf        # AWS provider configuration
│   ├── main.tf           # Main infrastructure resources
│   ├── variables.tf      # Input variables
│   └── outputs.tf        # Output values
├── scripts/              # Deployment scripts
│   ├── start_container.sh
│   ├── stop_container.sh
│   └── install_docker.sh
├── Dockerfile            # Container configuration
├── buildspec.yml         # CodeBuild configuration
├── appspec.yml          # CodeDeploy configuration
└── docker-compose.yml   # Local development
```

## 🚀 Quick Start

### Prerequisites
- AWS Account with appropriate permissions
- Terraform >= 1.0 installed
- Docker installed for local testing
- AWS CLI configured
- EC2 Key Pair created in target region

### 1. Local Development & Testing
```powershell
# Test the setup locally
.\test-local.ps1

# Or manually with Docker Compose
docker-compose up -d
# Access at http://localhost:3000
```

### 2. Infrastructure Deployment
```powershell
# Validate Terraform setup
.\validate-terraform.ps1

# Deploy infrastructure
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

### 3. Application Deployment
```bash
# SSH to EC2 instance (use output from terraform)
ssh -i your-key.pem ec2-user@<EC2-PUBLIC-IP>

# The application should auto-deploy via user-data script
# Check status: docker ps
# Access at: http://<EC2-PUBLIC-IP>
```

## Environment Variables

- `DB_HOST`: RDS endpoint
- `DB_NAME`: Database name
- `DB_USER`: Database username  
- `DB_PASS`: Database password

## CI/CD Pipeline

The pipeline automatically triggers on GitHub pushes:
1. **Source**: GitHub repository
2. **Build**: Docker image build and push to ECR
3. **Deploy**: Container deployment to EC2

## 📋 What's Included

### Application Components
- **index.php**: Main application with responsive form interface
- **db.php**: Database connection and operations class
- **config.php**: Environment-based configuration management

### Infrastructure Components
- **VPC & Networking**: Multi-AZ setup with public/private subnets
- **EC2 Instance**: Auto-configured with Docker and CodeDeploy agent
- **RDS MySQL**: Secure database in private subnet
- **ECR Repository**: Container image storage
- **Security Groups**: Least-privilege network access
- **IAM Roles**: Service-specific permissions

### CI/CD Components
- **buildspec.yml**: CodeBuild configuration for Docker builds
- **appspec.yml**: CodeDeploy configuration for EC2 deployment
- **Deployment Scripts**: Container lifecycle management
- **Pipeline Integration**: GitHub → Build → Deploy automation

## 🧪 Testing

### Local Testing
```powershell
.\test-local.ps1
# Access at http://localhost:3000
```

### Production Testing
```bash
# Access the deployed application
curl http://<EC2-PUBLIC-IP>
# Or open in browser: http://<EC2-PUBLIC-IP>

# Test form submission and database connectivity
# Fill out the form to verify end-to-end functionality
```
## 
📁 Project Structure Details

```
php-webapp/
├── app/                          # PHP Application
│   ├── index.php                # Main application page
│   ├── db.php                   # Database connection class
│   └── config.php               # Configuration management
├── terraform/                   # Infrastructure as Code
│   ├── provider.tf              # AWS provider configuration
│   ├── main.tf                  # Core infrastructure resources
│   ├── variables.tf             # Input variables
│   ├── outputs.tf               # Output values
│   ├── user_data.sh             # EC2 initialization script
│   └── terraform.tfvars.example # Example configuration
├── scripts/                     # Deployment automation
│   ├── install_docker.sh        # Docker installation
│   ├── start_container.sh       # Container startup
│   └── stop_container.sh        # Container cleanup
├── Dockerfile                   # Container configuration
├── docker-compose.yml           # Local development setup
├── buildspec.yml                # CodeBuild configuration
├── appspec.yml                  # CodeDeploy configuration
├── test-local.ps1               # Local testing script
├── validate-terraform.ps1       # Infrastructure validation
├── DEPLOYMENT.md                # Detailed deployment guide
├── ARCHITECTURE.md              # System architecture documentation
└── README.md                    # This file
```

## 🔧 Configuration

### Environment Variables
The application uses these environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_HOST` | Database hostname | localhost |
| `DB_NAME` | Database name | webapp_db |
| `DB_USER` | Database username | admin |
| `DB_PASS` | Database password | password |

### Terraform Variables
Key variables in `terraform.tfvars`:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | us-east-1 |
| `project_name` | Project identifier | php-webapp |
| `instance_type` | EC2 instance type | t3.micro |
| `key_pair_name` | EC2 key pair | (required) |
| `db_password` | RDS password | (required) |

## 🔄 CI/CD Pipeline

The automated pipeline triggers on GitHub pushes:

1. **Source Stage**: GitHub webhook triggers CodePipeline
2. **Build Stage**: CodeBuild builds and pushes Docker image to ECR
3. **Deploy Stage**: CodeDeploy updates container on EC2 instance

### Pipeline Configuration
- **Trigger**: GitHub repository changes
- **Build Environment**: Amazon Linux 2 with Docker
- **Deployment**: Rolling deployment to EC2 instances
- **Rollback**: Automatic on deployment failure

## 🛡️ Security Features

- **Network Isolation**: VPC with public/private subnet separation
- **Security Groups**: Restrictive inbound/outbound rules
- **IAM Roles**: Least-privilege service permissions
- **Database Security**: Private subnet placement, encrypted storage
- **Container Security**: ECR vulnerability scanning

## 📊 Monitoring & Logging

### Available Monitoring
- CloudWatch metrics for EC2 and RDS
- CodePipeline execution logs
- Docker container logs via CloudWatch Logs agent

### Recommended Enhancements
- CloudWatch alarms for resource utilization
- Application performance monitoring
- Custom application metrics
- Log aggregation and analysis

## 💰 Cost Estimation

**Monthly costs (us-east-1, approximate):**
- EC2 t3.micro: $8.50
- RDS db.t3.micro: $12.60
- ECR storage: $0.10/GB
- Data transfer: Variable
- CodeBuild: $0.005/minute

**Total estimated monthly cost: ~$25-30**

## 🚀 Production Enhancements

For production deployment, consider:

- **High Availability**: Multi-AZ deployment with load balancer
- **Auto Scaling**: EC2 Auto Scaling Groups
- **Database**: RDS Multi-AZ with read replicas
- **Caching**: ElastiCache for Redis/Memcached
- **CDN**: CloudFront for static assets
- **Secrets**: AWS Secrets Manager for credentials
- **Monitoring**: Enhanced CloudWatch monitoring and alerting
- **Backup**: Automated RDS and EBS snapshots

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `.\test-local.ps1`
5. Validate infrastructure with `.\validate-terraform.ps1`
6. Submit a pull request

## 📚 Additional Resources

- [Deployment Guide](DEPLOYMENT.md) - Detailed step-by-step instructions
- [Architecture Documentation](ARCHITECTURE.md) - System design and components
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

##  Support

If you encounter issues:

1. Check the [DEPLOYMENT.md](DEPLOYMENT.md) troubleshooting section
2. Review AWS CloudWatch logs
3. Verify IAM permissions and security groups
4. Open an issue with detailed error information

---

**Built with  for learning AWS, Docker, and Infrastructure as Code**