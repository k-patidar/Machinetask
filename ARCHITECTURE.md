# Architecture Overview

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                 AWS Cloud                                   │
│                                                                             │
│  ┌─────────────────┐    ┌──────────────────────────────────────────────┐   │
│  │   GitHub Repo   │    │                VPC (10.0.0.0/16)            │   │
│  │                 │    │                                              │   │
│  │  - PHP Code     │    │  ┌─────────────────┐  ┌─────────────────┐   │   │
│  │  - Dockerfile   │    │  │  Public Subnet  │  │ Private Subnet  │   │   │
│  │  - buildspec    │    │  │   (10.0.1.0/24) │  │  (10.0.10.0/24) │   │   │
│  │  - appspec      │    │  │                 │  │                 │   │   │
│  └─────────┬───────┘    │  │  ┌───────────┐  │  │  ┌───────────┐  │   │   │
│            │            │  │  │    EC2    │  │  │  │    RDS    │  │   │   │
│            │            │  │  │ Instance  │◄─┼──┼──┤  MySQL    │  │   │   │
│            │            │  │  │           │  │  │  │ Database  │  │   │   │
│            │            │  │  │Port 80,22 │  │  │  │Port 3306  │  │   │   │
│            │            │  │  └───────────┘  │  │  └───────────┘  │   │   │
│            │            │  └─────────────────┘  └─────────────────┘   │   │
│            │            │                                              │   │
│            │            └──────────────────────────────────────────────┘   │
│            │                                                               │
│            │  ┌─────────────────────────────────────────────────────────┐  │
│            │  │                 CI/CD Pipeline                          │  │
│            │  │                                                         │  │
│            │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │  │
│            └──┤  │   Source    │  │    Build    │  │   Deploy    │    │  │
│               │  │             │  │             │  │             │    │  │
│               │  │  GitHub     │─►│ CodeBuild   │─►│ CodeDeploy  │    │  │
│               │  │ Repository  │  │             │  │             │    │  │
│               │  │             │  │ Docker      │  │ EC2         │    │  │
│               │  └─────────────┘  │ Build & Push│  │ Deployment  │    │  │
│               │                   └─────┬───────┘  └─────────────┘    │  │
│               │                         │                             │  │
│               └─────────────────────────┼─────────────────────────────┘  │
│                                         │                                │
│  ┌─────────────────────────────────────┼─────────────────────────────┐  │
│  │                 ECR Repository      │                             │  │
│  │                                     ▼                             │  │
│  │  ┌─────────────────────────────────────────────────────────────┐  │  │
│  │  │              Docker Images                                  │  │  │
│  │  │                                                             │  │  │
│  │  │  php-webapp:latest                                          │  │  │
│  │  │  php-webapp:commit-hash                                     │  │  │
│  │  └─────────────────────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘

                                    │
                                    ▼
                            ┌───────────────┐
                            │   End Users   │
                            │               │
                            │ Web Browser   │
                            │ HTTP Requests │
                            └───────────────┘
```

## Component Details

### 1. Application Layer
- **PHP Web Application**: Simple form-based application with MySQL integration
- **Docker Container**: php:8.2-apache base image with application code
- **Port Configuration**: Container exposes port 80 for HTTP traffic

### 2. Infrastructure Layer

#### VPC & Networking
- **VPC**: 10.0.0.0/16 CIDR block
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24 (Multi-AZ)
- **Private Subnets**: 10.0.10.0/24, 10.0.11.0/24 (Multi-AZ)
- **Internet Gateway**: Provides internet access to public subnets
- **Route Tables**: Configured for public internet access

#### Compute
- **EC2 Instance**: t3.micro (or configurable)
- **AMI**: Amazon Linux 2
- **Security Groups**: 
  - Inbound: SSH (22), HTTP (80)
  - Outbound: All traffic
- **IAM Role**: ECR access, S3 access for CodeDeploy

#### Database
- **RDS MySQL**: 8.0 engine
- **Instance Class**: db.t3.micro (or configurable)
- **Multi-AZ**: Optional (configurable)
- **Security Groups**: MySQL (3306) from EC2 only
- **Subnet Group**: Private subnets only

#### Container Registry
- **ECR Repository**: Stores Docker images
- **Image Scanning**: Enabled for security
- **Lifecycle Policy**: Configurable retention

### 3. CI/CD Pipeline

#### Source Stage
- **GitHub Integration**: Webhook-triggered pipeline
- **Branch**: main (configurable)
- **Artifacts**: Source code, Dockerfile, deployment scripts

#### Build Stage
- **CodeBuild Project**: 
  - Environment: Amazon Linux 2
  - Runtime: Docker
  - Build Commands: Docker build, tag, push to ECR
- **Artifacts**: imagedefinitions.json, deployment scripts

#### Deploy Stage
- **CodeDeploy Application**: 
  - Platform: EC2/On-premises
  - Deployment Group: EC2 instances with specific tags
  - Deployment Configuration: AllAtOnce (configurable)

### 4. Security Configuration

#### Network Security
- **Security Groups**: Least privilege access
- **NACLs**: Default (can be customized)
- **Private Subnets**: Database isolation

#### IAM Security
- **EC2 Role**: ECR pull permissions, S3 access
- **CodeBuild Role**: ECR push permissions, CloudWatch logs
- **CodePipeline Role**: Service orchestration permissions
- **CodeDeploy Role**: EC2 deployment permissions

#### Data Security
- **RDS Encryption**: At rest and in transit
- **ECR Scanning**: Vulnerability detection
- **Secrets Management**: Environment variables (can be enhanced with AWS Secrets Manager)

## Data Flow

### 1. Development Workflow
```
Developer → Git Push → GitHub → CodePipeline Trigger
```

### 2. Build Process
```
CodePipeline → CodeBuild → Docker Build → ECR Push
```

### 3. Deployment Process
```
CodeBuild → CodeDeploy → EC2 Instance → Container Update
```

### 4. Application Request Flow
```
User → Internet Gateway → EC2 Instance → PHP Application → RDS MySQL
```

## Scalability Considerations

### Current Architecture
- Single EC2 instance
- Single RDS instance
- Manual scaling

### Future Enhancements
- **Auto Scaling Group**: Multiple EC2 instances
- **Application Load Balancer**: Traffic distribution
- **RDS Read Replicas**: Database scaling
- **ElastiCache**: Caching layer
- **CloudFront**: CDN for static assets

## Monitoring & Logging

### Available Monitoring
- **CloudWatch Metrics**: EC2, RDS basic metrics
- **CodePipeline Logs**: Build and deployment logs
- **Application Logs**: Docker container logs

### Recommended Additions
- **CloudWatch Alarms**: Resource utilization alerts
- **AWS X-Ray**: Application tracing
- **CloudTrail**: API call logging
- **Custom Metrics**: Application-specific monitoring

## Cost Optimization

### Current Costs (Estimated Monthly)
- **EC2 t3.micro**: ~$8.50
- **RDS db.t3.micro**: ~$12.60
- **Data Transfer**: Variable
- **ECR Storage**: ~$0.10/GB
- **CodeBuild**: $0.005/minute

### Optimization Strategies
- **Reserved Instances**: Long-term cost savings
- **Spot Instances**: Development environments
- **RDS Scheduling**: Stop/start for development
- **Image Cleanup**: ECR lifecycle policies