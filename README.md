# SimpleTimeService

A simple python based tool to display a user's current timestamp and IP Address in the web browser.

## Dev Setup

Clone the code locally and run the following commands in your terminal:

```bash

# Navigate into Applicatuion Directory

cd /app

# Create virtual environment
python -m venv venv

# Activate virtual environment (macOS/Linux)
source venv/bin/activate

# Install requirements
pip install -r requirements.txt
```

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

## Cost Optimization

```bash
# Run the app
python app.py
```


## Docker Setup

To Build and Run the application using the Dockerfile.

```bash

#To Pull the Docker Image

docker pull digitalkid/simple-time-service:latest

#To run the application

docker run -p 8000:8000 simple-time-service

```

Open http://localhost:8000 (or http://127.0.0.1:8000) in your browser.  
If you're running the app in Docker, make sure port 8000 is forwarded (for example: docker run -p 8000:8000 simple-time-service).