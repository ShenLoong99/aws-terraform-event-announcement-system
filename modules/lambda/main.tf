# Data source to package the Subscribe Lambda
data "archive_file" "sub_zip" {
  type        = "zip"
  source_file = "${path.module}/src/subscriber.js"
  output_path = "${path.module}/src/lambda_subscriber.zip"
}

# Data source to package the Create Event Lambda
data "archive_file" "event_zip" {
  type        = "zip"
  source_file = "${path.module}/src/create_event.js"
  output_path = "${path.module}/src/lambda_create.zip"
}

# SNS Topic
resource "aws_sns_topic" "event_updates" {
  name              = "event-announcement-topic"
  kms_master_key_id = "alias/aws/sns"
}

# Lambda function definitions and IAM role
resource "aws_iam_role" "lambda_role" {
  name = "event_project_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Grant Lambda permissions to write to CloudWatch Logs and read/write to S3 and SNS
resource "aws_iam_role_policy" "lambda_permissions" {
  name = "event_project_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sns:Publish", "sns:Subscribe"],
        Effect   = "Allow",
        Resource = aws_sns_topic.event_updates.arn
      },
      {
        Action   = "sqs:SendMessage"
        Effect   = "Allow"
        Resource = aws_sqs_queue.lambda_dlq.arn
      },
      {
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Effect = "Allow",
        Resource = [
          "${aws_cloudwatch_log_group.sub_logs.arn}:*"
        ]
      }
    ]
  })
}

# SQS Queue for Lambda Dead Letter Queue (DLQ)
resource "aws_sqs_queue" "lambda_dlq" {
  name                    = "event-announcement-lambda-dlq"
  sqs_managed_sse_enabled = true
}

# Grant Lambda permissions to read/write to S3
resource "aws_lambda_function" "subscribe" {
  filename         = data.archive_file.sub_zip.output_path
  source_code_hash = data.archive_file.sub_zip.output_base64sha256
  function_name    = "SubscribeLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "subscriber.handler"
  runtime          = "nodejs20.x"

  # LIMITS to reduce costs
  memory_size = 128 # Minimum RAM (cheapest/free)
  timeout     = 10  # Kill function after 10 seconds

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.event_updates.arn
    }
  }

  tags = {
    Function = "Subscriber"
  }
}

# Grant Lambda permissions to write to CloudWatch Logs and read/write to S3 and SNS
resource "aws_lambda_function" "create_event" {
  filename         = data.archive_file.event_zip.output_path
  source_code_hash = data.archive_file.event_zip.output_base64sha256
  function_name    = "CreateEventLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "create_event.handler"
  runtime          = "nodejs20.x"

  # LIMITS to reduce costs
  memory_size = 128
  timeout     = 20 # S3/SNS writes might need slightly longer than sub

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      S3_BUCKET     = var.bucket_id
      SNS_TOPIC_ARN = aws_sns_topic.event_updates.arn
    }
  }

  tags = {
    Function = "Event-Creator"
  }
}

# Log Group for Subscribe Lambda
resource "aws_cloudwatch_log_group" "sub_logs" {
  name              = "/aws/lambda/${aws_lambda_function.subscribe.function_name}"
  retention_in_days = 1
}

# Log Group for Create Event Lambda
resource "aws_cloudwatch_log_group" "event_logs" {
  name              = "/aws/lambda/${aws_lambda_function.create_event.function_name}"
  retention_in_days = 1
}
