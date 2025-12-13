# ========================================
# API Gateway (HTTP API)
# ========================================

resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"
  description   = "API Gateway for ${var.project_name}"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["*"]
    max_age       = 300
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-api"
      Environment = var.environment
      Project     = var.project_name
    },
    var.additional_tags
  )
}

# ========================================
# Lambda Integration
# ========================================

resource "aws_apigatewayv2_integration" "lambda" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = module.lambda.lambda_function_invoke_arn

  payload_format_version = "2.0"
  timeout_milliseconds   = var.lambda_timeout * 1000
}

# ========================================
# API Gateway Route
# ========================================

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# ========================================
# API Gateway Stage
# ========================================

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  default_route_settings {
    throttling_burst_limit = var.api_gateway_throttle_burst_limit
    throttling_rate_limit  = var.api_gateway_throttle_rate_limit
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-api-stage"
      Environment = var.environment
      Project     = var.project_name
    },
    var.additional_tags
  )
}

# ========================================
# CloudWatch Log Group for API Gateway
# ========================================

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = var.lambda_log_retention_days

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-api-logs"
      Environment = var.environment
      Project     = var.project_name
    },
    var.additional_tags
  )
}

# ========================================
# Lambda Permission for API Gateway
# ========================================

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
