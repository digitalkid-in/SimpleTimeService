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


## Lambda Deployment (AWS) (Serverless)

Deploy to AWS Lambda with API Gateway:

```bash
cd terraform
terraform init
terraform apply

# Terraform will:
# 1. Create VPC, subnets, security groups
# 2. Build Docker image from terraform/app/
# 3. Push to ECR
# 4. Deploy Lambda function
# 5. Create API Gateway
```

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

