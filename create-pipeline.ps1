# Create CodePipeline for PHP Web App

Write-Host "Creating CodePipeline..." -ForegroundColor Yellow

# Check if pipeline exists
try {
    aws codepipeline get-pipeline --name php-webapp-pipeline --region us-east-1 2>$null
    Write-Host "Pipeline already exists!" -ForegroundColor Green
} catch {
    Write-Host "Creating new pipeline..." -ForegroundColor Cyan
    
    # Create pipeline JSON
    $pipelineJson = @"
{
    "pipeline": {
        "name": "php-webapp-pipeline",
        "roleArn": "arn:aws:iam::430503858617:role/php-webapp-codepipeline-role",
        "artifactStore": {
            "type": "S3",
            "location": "php-webapp-codepipeline-artifacts-mj1x50zp"
        },
        "stages": [
            {
                "name": "Source",
                "actions": [
                    {
                        "name": "Source",
                        "actionTypeId": {
                            "category": "Source",
                            "owner": "ThirdParty",
                            "provider": "GitHub",
                            "version": "1"
                        },
                        "configuration": {
                            "Owner": "k-patidar",
                            "Repo": "Machinetask",
                            "Branch": "master",
                            "OAuthToken": "YOUR_GITHUB_TOKEN"
                        },
                        "outputArtifacts": [
                            {
                                "name": "SourceOutput"
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Build",
                "actions": [
                    {
                        "name": "Build",
                        "actionTypeId": {
                            "category": "Build",
                            "owner": "AWS",
                            "provider": "CodeBuild",
                            "version": "1"
                        },
                        "configuration": {
                            "ProjectName": "php-webapp-build"
                        },
                        "inputArtifacts": [
                            {
                                "name": "SourceOutput"
                            }
                        ],
                        "outputArtifacts": [
                            {
                                "name": "BuildOutput"
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Deploy",
                "actions": [
                    {
                        "name": "Deploy",
                        "actionTypeId": {
                            "category": "Deploy",
                            "owner": "AWS",
                            "provider": "CodeDeploy",
                            "version": "1"
                        },
                        "configuration": {
                            "ApplicationName": "php-webapp",
                            "DeploymentGroupName": "php-webapp-deployment-group"
                        },
                        "inputArtifacts": [
                            {
                                "name": "BuildOutput"
                            }
                        ]
                    }
                ]
            }
        ]
    }
}
"@

    # Save to file
    $pipelineJson | Out-File -FilePath "pipeline.json" -Encoding UTF8
    
    Write-Host "Pipeline JSON created. Manual setup required in AWS Console." -ForegroundColor Yellow
    Write-Host "Go to: https://console.aws.amazon.com/codesuite/codepipeline/pipelines" -ForegroundColor Cyan
}

# Check existing resources
Write-Host "`nExisting CI/CD Resources:" -ForegroundColor Green
Write-Host "CodeBuild Projects:" -ForegroundColor Cyan
aws codebuild list-projects --region us-east-1 --query 'projects'

Write-Host "`nCodeDeploy Applications:" -ForegroundColor Cyan
aws codedeploy list-applications --region us-east-1 --query 'applications'

Write-Host "`nECR Repositories:" -ForegroundColor Cyan
aws ecr describe-repositories --region us-east-1 --query 'repositories[].repositoryName'