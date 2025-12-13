# ========================================
# Automated Docker Build and Push
# Runs automatically before Lambda creation
# ========================================

resource "null_resource" "docker_build_push" {
  triggers = {
    # Rebuild when app files change
    dockerfile_hash    = filesha1("${path.module}/../app/Dockerfile")
    app_py_hash        = filesha1("${path.module}/../app/app.py")
    requirements_hash  = filesha1("${path.module}/../app/requirements.txt")
    ecr_url            = aws_ecr_repository.main.repository_url
  }

  provisioner "local-exec" {
    command = <<-EOF
      set -e  # Exit on any error
      
      echo "Checking Docker daemon..."
      if ! docker info > /dev/null 2>&1; then
        echo "ERROR: Docker daemon is not running!"
        echo "Please start Docker Desktop and try again."
        exit 1
      fi
      
      echo "Building and pushing Docker image to ECR..."
      aws ecr get-login-password --region ${var.aws_region} | \
        docker login --username AWS --password-stdin ${aws_ecr_repository.main.repository_url}
      
      docker build --platform linux/amd64 \
        --provenance=false \
        -t ${aws_ecr_repository.main.repository_url}:latest \
        ${path.module}/../app
      
      docker push ${aws_ecr_repository.main.repository_url}:latest
      
      echo "Image pushed successfully!"
    EOF
  }

  depends_on = [aws_ecr_repository.main]
}
