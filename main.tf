provider "aws" {
  region = "ap-northeast-1"
}

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
