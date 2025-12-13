# ========================================
# ECR Repository
# ========================================

resource "aws_ecr_repository" "main" {
  name                 = "${var.project_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true  # Allow deletion even with images

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-ecr"
      Environment = var.environment
      Project     = var.project_name
    },
    var.additional_tags
  )
}

# ========================================
# ECR Lifecycle Policy
# ========================================

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
