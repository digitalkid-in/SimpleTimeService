## Simple Time Service

A simple python based tool to display a user's current timestamp and IP Address in the web browser.

## Getting Started

Clone the repository and navigate to the project directory:

```bash
git clone https://github.com/rohenp/SimpleTimeService.git
cd SimpleTimeService
```

## Prerequisites

Before you begin, ensure you have the following installed on your machine:

### Required Software

- **Docker Desktop** - For building and running containerized applications
  - Download: [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
  - Verify installation: `docker --version`

- **Terraform** - For infrastructure as code deployment
  - Download: [https://www.terraform.io/downloads](https://www.terraform.io/downloads)
  - Verify installation: `terraform --version`

- **AWS CLI** - For AWS account configuration and management
  - Download: [https://aws.amazon.com/cli/](https://aws.amazon.com/cli/)
  - Verify installation: `aws --version`

### AWS Account Requirements

- **Active AWS Account** with appropriate permissions
- **IAM User** with the following permissions:
  - VPC management (create/delete VPCs, subnets, security groups)
  - ECR (Elastic Container Registry) access
  - Lambda function management
  - API Gateway management
  - IAM role creation for Lambda execution
  - CloudWatch Logs access

- **AWS Credentials Configured**:
  ```bash
  aws configure
  # Enter your AWS Access Key ID
  # Enter your AWS Secret Access Key
  # Enter your default region (e.g., ap-south-1)
  # Enter your default output format (e.g., json)
  ```

### Optional (for Local Development)

- **Python 3.9+** - If running the Flask app directly without Docker
  - Verify installation: `python --version` or `python3 --version`


## Project Structure
```
SimpleTimeService/
├── app/                          # Local development
│   ├── Dockerfile               # Simple Flask server
│   ├── app.py                   # Flask app
│   └── requirements.txt         # Only flask
│
└── terraform/
    ├── app/                      # Lambda deployment (separate copy)
    │   ├── Dockerfile           # Lambda with awslambdaric
    │   ├── app.py               # Flask app with lambda_handler
    │   └── requirements.txt     # flask + serverless-wsgi
    └── *.tf                     # Terraform configuration
```

## Docker Setup

To Run the Application on your Local.

```bash

#To Pull the Docker Image
docker pull digitalkid/simple-time-service:latest

#To run the application
docker run -p 8000:8000 simple-time-service

```

Open http://localhost:8000 (or http://127.0.0.1:8000) in your browser.  
If you're running the app in Docker, make sure port 8000 is forwarded (for example: docker run -p 8000:8000 simple-time-service).


## Single-Command Deployment (AWS Lambda)

### Overview

Everything deploys in **ONE command**! Terraform automatically:
1. Creates VPC, subnets, endpoints, security groups, ECR
2. Builds and pushes Docker image to ECR
3. Creates Lambda function (after image is pushed)
4. Creates API Gateway

### Deployment

```bash
cd terraform
terraform init
terraform apply
```

That's it! ✅

### What Happens

**Terraform execution order:**
1. ✅ VPC with 2 public + 2 private subnets
2. ✅ Internet Gateway
3. ✅ VPC Endpoints (ECR API, ECR Docker, S3, CloudWatch)
4. ✅ Security Groups
5. ✅ ECR Repository
6. 🔨 **Docker Build & Push** (null_resource with depends_on)
7. ✅ Lambda Function (depends on Docker build)
8. ✅ API Gateway
9. ✅ Lambda Permission for API Gateway

### Testing

```bash
# Get API URL
API_URL=$(terraform output -raw api_gateway_url)

# Test
curl $API_URL
```

Expected response:
```json
{
  "timestamp": "2025-12-13T15:45:00Z",
  "ip": "1.2.3.4"
}
```

### Updating Application

When you modify code in `app/`:

```bash
terraform apply
```

Terraform detects changes to:
- `app/Dockerfile`
- `app/app.py`
- `app/requirements.txt`

And automatically rebuilds/pushes the image and updates Lambda.

### Architecture

```
terraform apply
    ↓
1. Create VPC + Subnets + Endpoints + Security Groups + ECR
    ↓
2. null_resource: Build Docker → Push to ECR
    ↓ (depends_on)
3. Create Lambda (image now exists!)
    ↓
4. Create API Gateway
    ↓
✅ Done!
```

### Key Files

- `docker_build.tf` - Automated Docker build/push
- `lambda.tf` - Lambda with `depends_on = [null_resource.docker_build_push]`
- `api_gateway.tf` - HTTP API Gateway

### Benefits

✅ **Single command deployment**  
✅ **Automatic Docker build**  
✅ **Correct dependency order**  
✅ **Meets all assignment requirements**  
✅ **Cost optimized** (~$14-21/month with VPC endpoints, no NAT Gateway)

**Note**: The `terraform/app/` folder is a separate copy optimized for Lambda with `serverless-wsgi` and Lambda Runtime Interface Client. You can modify `app/` for local development without affecting Lambda deployment.

## Troubleshooting

### Common Issues

1. **Docker Build Fails**: Ensure Docker Desktop is running
2. **Lambda Timeout**: Check CloudWatch logs for errors
3. **API Gateway 503**: Lambda may still be initializing

### Logs

```bash
# Lambda logs
aws logs tail /aws/lambda/simple-time-service-dev --region ap-south-1 --follow

# API Gateway logs
aws logs tail /aws/apigateway/simple-time-service-dev --region ap-south-1 --follow
```

## Cleanup

To destroy all infrastructure:

```bash
cd terraform
terraform destroy
```

> **⚠️ Important**: Lambda ENI (Elastic Network Interface) deletion takes **5-10 minutes**. This is a known AWS limitation when Lambda functions are deployed in VPCs. Terraform will wait for ENIs to detach before destroying subnets and security groups.

**What to expect during destroy:**
- Most resources delete quickly (< 1 minute)
- Lambda ENIs take 5-10 minutes to detach
- Subnets and security groups wait for ENI detachment
- Total destroy time: ~10-15 minutes

**If destroy is interrupted:**
- Wait 10 minutes for ENIs to detach naturally
- Run `terraform destroy` again
- Or manually delete ENIs via AWS Console/CLI

## CI/CD with GitHub Actions

This project includes automated Terraform deployment using GitHub Actions.

### Features

- ✅ **Automatic `terraform plan`** on pull requests
- ✅ **Automatic `terraform apply`** when merged to main
- ✅ **Plan results posted** as PR comments
- ✅ **Deployment testing** - automatically tests API after deployment
- ✅ **Manual approval** option for production deployments

### Quick Setup

1. **Create AWS IAM user** for GitHub Actions with required permissions
2. **Add GitHub secrets**:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. **Push to main** or create a PR to trigger the workflow

**Detailed setup instructions**: See [.github/GITHUB_ACTIONS_SETUP.md](./.github/GITHUB_ACTIONS_SETUP.md)

### Workflow Behavior

**On Pull Request:**
- Runs `terraform plan`
- Posts plan as PR comment
- No infrastructure changes

**On Push to Main:**
- Runs `terraform apply`
- Tests deployed API
- Posts deployment summary with API URL

