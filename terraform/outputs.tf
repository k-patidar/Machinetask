output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.web.public_dns
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_instance.web.public_ip}"
}

output "ssh_command" {
  description = "SSH command to connect to EC2 instance"
  value       = "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.web.public_ip}"
}

output "database_connection_string" {
  description = "Database connection details"
  value = {
    host     = aws_db_instance.main.endpoint
    database = var.db_name
    username = var.db_username
  }
  sensitive = false
}

output "codepipeline_bucket" {
  description = "S3 bucket for CodePipeline artifacts"
  value       = aws_s3_bucket.codepipeline_artifacts.bucket
}

output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = aws_codebuild_project.app.name
}

output "codedeploy_application_name" {
  description = "CodeDeploy application name"
  value       = aws_codedeploy_app.app.name
}