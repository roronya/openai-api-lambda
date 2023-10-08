provider "aws" {
  region = "ap-northeast-1"
}

# lambda
resource "aws_iam_role" "lambda_role" {
  name = "OpenAILambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
    }]
  })
}

resource "aws_lambda_function" "openai_forwarder" {
  filename      = "function.zip"
  function_name = "OpenAI_Forwarder"
  role          = aws_iam_role.lambda_role.arn
  handler       = "forward_to_openai.lambda_handler"
  runtime       = "python3.11"

  environment {
    variables = {
      OPENAI_API_KEY = "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"
    }
  }
}

output "lambda_arn" {
  value = aws_lambda_function.openai_forwarder.arn
}

# API Gateway
resource "aws_api_gateway_rest_api" "openai_api" {
  name        = "OpenAIProxyAPI"
  description = "API for forwarding requests to OpenAI"
}

resource "aws_api_gateway_resource" "openai_resource" {
  rest_api_id = aws_api_gateway_rest_api.openai_api.id
  parent_id   = aws_api_gateway_rest_api.openai_api.root_resource_id
  path_part   = "query"
}

resource "aws_api_gateway_method" "openai_post" {
  rest_api_id   = aws_api_gateway_rest_api.openai_api.id
  resource_id   = aws_api_gateway_resource.openai_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "openai_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.openai_api.id
  resource_id = aws_api_gateway_resource.openai_resource.id
  http_method = aws_api_gateway_method.openai_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.openai_forwarder.invoke_arn
}

resource "aws_api_gateway_deployment" "openai_deployment" {
  depends_on = [aws_api_gateway_integration.openai_lambda_integration]

  rest_api_id = aws_api_gateway_rest_api.openai_api.id
  stage_name  = "prod"
}

output "api_url" {
  value = "${aws_api_gateway_deployment.openai_deployment.invoke_url}/query"
}

# add IAM role to API Gateway to call lambda
resource "aws_iam_policy" "lambda_api_gateway_invoke" {
  name        = "LambdaAPIGatewayInvoke"
  description = "Allows API Gateway to invoke the Lambda function"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "lambda:InvokeFunction"
      ],
      Effect   = "Allow",
      Resource = aws_lambda_function.openai_forwarder.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_api_gateway_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_api_gateway_invoke.arn
}
