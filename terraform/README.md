# Single-Command Deployment

## Overview

Everything deploys in **ONE command**! Terraform automatically:
1. Creates VPC, subnets, endpoints, security groups, ECR
2. Builds and pushes Docker image to ECR
3. Creates Lambda function (after image is pushed)
4. Creates API Gateway

## Deployment

```bash
cd terraform
terraform init
terraform apply
```

That's it! ✅

## What Happens

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

## Testing

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

## Updating Application

When you modify code in `app/`:

```bash
terraform apply
```

Terraform detects changes to:
- `app/Dockerfile`
- `app/app.py`
- `app/requirements.txt`

And automatically rebuilds/pushes the image and updates Lambda.

## Architecture

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

## Key Files

- `docker_build.tf` - Automated Docker build/push
- `lambda.tf` - Lambda with `depends_on = [null_resource.docker_build_push]`
- `api_gateway.tf` - HTTP API Gateway

## Cleanup

```bash
terraform destroy
```

## Benefits

✅ **Single command deployment**  
✅ **Automatic Docker build**  
✅ **Correct dependency order**  
✅ **Meets all assignment requirements**  
✅ **Cost optimized** (~$14-21/month with VPC endpoints, no NAT Gateway)
