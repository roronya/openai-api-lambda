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

resource "aws_iam_role_policy" "lambda_logging_policy" {
  name   = "LambdaLogging"
  role   = aws_iam_role.lambda_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Effect   = "Allow",
      Resource = "arn:aws:logs:*:*:*"
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
      OPENAI_API_KEY = "SHOULD BE OVERWRITE"
    }
  }
}
