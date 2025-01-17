
provider "aws" {
  region = "us-east-1"
}
# Create SNS Topic 
resource "aws_sns_topic" "nba_games_update" {
  name = "gd_sns_topic"
}

# Create SNS Subscription (e.g., Email)
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.nba_games_update.arn
  protocol  = "email"
  endpoint  = var.email_subscriber
}

#Create IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "gd_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attaching Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "sns_policy" {
  role  = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "sns_publish_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

#Creating AWS Lambda Function
resource "aws_lambda_function" "gd_lamda_function" {
  function_name = "gd_lamda"
  runtime       = "python3.13"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  filename      = "lambda_function.zip"
   environment {
    variables = {
      NBA_API_KEY    = var.nba_api_key
      SNS_TOPIC_ARN  = aws_sns_topic.nba_games_update.arn
    }
  }
}

# EventBridge Rule for Scheduling
resource "aws_cloudwatch_event_rule" "nba_schedule_rule" {
  name                = "nba-schedule-rule"
  schedule_expression = "rate(1 minute)" # Adjust the schedule as required
}

# EventBridge Target for Lambda
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.nba_schedule_rule.name
  arn  = aws_lambda_function.gd_lamda_function.arn
}

# Grant Permission for EventBridge to Invoke Lambda
resource "aws_lambda_permission" "eventbridge_permission" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.gd_lamda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.nba_schedule_rule.arn
}
