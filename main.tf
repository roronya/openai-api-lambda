terraform {
  required_version = "1.5.6"
  backend "s3" {
    bucket = "tfstate-openai-forwarder"
    key = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}


# openai-forwarderを実行するIAMロールの定義
resource "aws_iam_role" "lambda_role" {
  name = "openai-forwarder-role"

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

# ↑のIAMロールにCloudWatchへの書き込み権限を付けてロギングできるようにしている
resource "aws_iam_role_policy" "lambda_logging_policy" {
  name   = "lambda-logging"
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
  function_name = "openai-forwarder"
  role          = aws_iam_role.lambda_role.arn
  handler       = "openai-forwarder.lambda_handler"
  runtime       = "python3.11"

  environment {
    variables = {
      OPENAI_API_KEY = "SHOULD BE OVERWRITE"
    }
  }
}
