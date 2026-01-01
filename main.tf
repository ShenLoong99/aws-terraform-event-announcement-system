provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "Production"
      Project     = "EventAnnouncements"
      ManagedBy   = "Terraform"
    }
  }
}

# Data source to package the Subscribe Lambda
data "archive_file" "sub_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/subscriber.js"
  output_path = "${path.module}/lambda/lambda_subscriber.zip"
}

# Data source to package the Create Event Lambda
data "archive_file" "event_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/create_event.js"
  output_path = "${path.module}/lambda/lambda_create.zip"
}

// S3 Bucket (Frontend)
resource "aws_s3_bucket" "website" {
  # Generates a name like: event-announcement-8a2f1b3c
  bucket = "event-announcement-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "Event-Frontend-Storage"
  }
}

# Protects your events.json from accidental deletion/corruption
resource "aws_s3_bucket_versioning" "website_versioning" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Generate a random suffix for the bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.website.id
  index_document { suffix = "index.html" }
}

// S3 Bucket Public Access Configuration
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.website.id

  # These must be FALSE to allow the public bucket policy
  block_public_acls       = true  # Best Practice: Use Policies, not ACLs
  block_public_policy     = false # Must be false to allow your website policy
  ignore_public_acls      = true
  restrict_public_buckets = false # Must be false for public website access
}

// S3 Bucket Policy
resource "aws_s3_bucket_policy" "allow_public" {
  bucket = aws_s3_bucket.website.id

  # CRITICAL: Wait for the access blocks to be removed first
  depends_on = [aws_s3_bucket_public_access_block.public]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.website.arn}/*"
    }]
  })
}

# Upload index.html
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.website.id
  key    = "index.html"

  # Wait for the bucket and its website/policy config to be READY
  depends_on = [
    aws_s3_bucket_website_configuration.hosting,
    aws_s3_bucket_policy.allow_public
  ]

  # This dynamically pulls the output into your HTML
  content = templatefile("${path.module}/frontend/index.html.tftpl", {
    api_url = "${aws_api_gateway_stage.prod.invoke_url}"
  })
  content_type = "text/html"
}

# Upload style.css
resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.website.id
  key          = "style.css"
  source       = "${path.module}/frontend/style.css"
  content_type = "text/css"

  # Wait for the bucket and its website/policy config to be READY
  depends_on = [
    aws_s3_bucket_website_configuration.hosting,
    aws_s3_bucket_policy.allow_public
  ]
}

# Upload initial events.json
resource "aws_s3_object" "data" {
  bucket       = aws_s3_bucket.website.id
  key          = "events.json"
  source       = "${path.module}/frontend/events.json"
  content_type = "application/json"

  # Wait for the bucket and its website/policy config to be READY
  depends_on = [
    aws_s3_bucket_website_configuration.hosting,
    aws_s3_bucket_policy.allow_public
  ]
}

// SNS Topic
resource "aws_sns_topic" "event_updates" {
  name = "event-announcement-topic"
}

# iam.tf snippet
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

# lambda.tf snippet
resource "aws_lambda_function" "subscribe" {
  filename         = data.archive_file.sub_zip.output_path
  source_code_hash = data.archive_file.sub_zip.output_base64sha256
  function_name    = "SubscribeLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "subscriber.handler"
  runtime          = "nodejs18.x"

  # LIMITS to reduce costs
  memory_size = 128 # Minimum RAM (cheapest/free)
  timeout     = 10  # Kill function after 10 seconds

  environment { variables = { SNS_TOPIC_ARN = aws_sns_topic.event_updates.arn } }

  tags = {
    Function = "Subscriber"
  }
}

resource "aws_lambda_function" "create_event" {
  filename         = data.archive_file.event_zip.output_path
  source_code_hash = data.archive_file.event_zip.output_base64sha256
  function_name    = "CreateEventLambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "create_event.handler"
  runtime          = "nodejs18.x"

  # LIMITS to reduce costs
  memory_size = 128
  timeout     = 20 # S3/SNS writes might need slightly longer than sub

  environment {
    variables = {
      S3_BUCKET     = aws_s3_bucket.website.id
      SNS_TOPIC_ARN = aws_sns_topic.event_updates.arn
    }
  }

  tags = {
    Function = "Event-Creator"
  }
}

# Create the REST API
resource "aws_api_gateway_rest_api" "event_api" {
  name        = "EventAnnouncementAPI"
  description = "API for Event Subscriptions and Creation"
}

# --- SUBSCRIBE ENDPOINT ---
resource "aws_api_gateway_resource" "subscribe" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  parent_id   = aws_api_gateway_rest_api.event_api.root_resource_id
  path_part   = "subscribe"
}

// The actual POST method for subscribing
resource "aws_api_gateway_method" "sub_post" {
  rest_api_id   = aws_api_gateway_rest_api.event_api.id
  resource_id   = aws_api_gateway_resource.subscribe.id
  http_method   = "POST"
  authorization = "NONE"
}

// Integrate the POST method with your Subscribe Lambda
resource "aws_api_gateway_integration" "sub_lambda_int" {
  rest_api_id             = aws_api_gateway_rest_api.event_api.id
  resource_id             = aws_api_gateway_resource.subscribe.id
  http_method             = aws_api_gateway_method.sub_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY" # Use PROXY so Lambda can send headers
  uri                     = aws_lambda_function.subscribe.invoke_arn
}

// Give API Gateway permission to call this Lambda
resource "aws_lambda_permission" "apigw_sub" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscribe.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.event_api.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "sub_options" {
  rest_api_id   = aws_api_gateway_rest_api.event_api.id
  resource_id   = aws_api_gateway_resource.subscribe.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

// Define the Method Response
resource "aws_api_gateway_method_response" "sub_options_200" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  resource_id = aws_api_gateway_resource.subscribe.id
  http_method = aws_api_gateway_method.sub_options.http_method
  status_code = "200"

  # Define which headers this response is allowed to return
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

// Ensure Integer Status Code in Mock Integration
resource "aws_api_gateway_integration" "sub_options_int" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  resource_id = aws_api_gateway_resource.subscribe.id
  http_method = aws_api_gateway_method.sub_options.http_method
  type        = "MOCK"

  # FIX: statusCode must be an integer, NOT a string "200"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

// Verify Integration Response
resource "aws_api_gateway_integration_response" "sub_options_int_resp" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  resource_id = aws_api_gateway_resource.subscribe.id
  http_method = aws_api_gateway_method.sub_options.http_method
  status_code = aws_api_gateway_method_response.sub_options_200.status_code

  depends_on = [aws_api_gateway_method_response.sub_options_200]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# --- CREATE-EVENT ENDPOINT ---
resource "aws_api_gateway_resource" "create_event" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  parent_id   = aws_api_gateway_rest_api.event_api.root_resource_id
  path_part   = "create-event"
}

// The actual POST method for creating events
resource "aws_api_gateway_method" "event_post" {
  rest_api_id   = aws_api_gateway_rest_api.event_api.id
  resource_id   = aws_api_gateway_resource.create_event.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integrate POST with the Create Event Lambda
resource "aws_api_gateway_integration" "event_lambda_int" {
  rest_api_id             = aws_api_gateway_rest_api.event_api.id
  resource_id             = aws_api_gateway_resource.create_event.id
  http_method             = aws_api_gateway_method.event_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_event.invoke_arn
}

# Permission for API Gateway to call Create Event Lambda
resource "aws_lambda_permission" "apigw_event" {
  statement_id  = "AllowAPIGatewayInvokeEvent"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_event.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.event_api.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "event_options" {
  rest_api_id   = aws_api_gateway_rest_api.event_api.id
  resource_id   = aws_api_gateway_resource.create_event.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Define the Method Response for OPTIONS
resource "aws_api_gateway_method_response" "event_options_200" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  resource_id = aws_api_gateway_resource.create_event.id
  http_method = aws_api_gateway_method.event_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "event_options_int" {
  rest_api_id       = aws_api_gateway_rest_api.event_api.id
  resource_id       = aws_api_gateway_resource.create_event.id
  http_method       = aws_api_gateway_method.event_options.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}

# Define the Integration Response to return the actual headers
resource "aws_api_gateway_integration_response" "event_options_int_resp" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  resource_id = aws_api_gateway_resource.create_event.id
  http_method = aws_api_gateway_method.event_options.http_method
  status_code = aws_api_gateway_method_response.event_options_200.status_code

  depends_on = [aws_api_gateway_method_response.event_options_200]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Deployment (Triggers a new deployment when the API configuration changes)
resource "aws_api_gateway_deployment" "event_deploy" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id

  # Ensures ALL methods and integrations exist before deploying
  depends_on = [
    aws_api_gateway_method.sub_post,
    aws_api_gateway_integration.sub_lambda_int,
    aws_api_gateway_method.sub_options,
    aws_api_gateway_integration.sub_options_int,
    aws_api_gateway_method.event_post,
    aws_api_gateway_integration.event_lambda_int,
    aws_api_gateway_method.event_options,
    aws_api_gateway_integration.event_options_int,
    aws_api_gateway_integration_response.sub_options_int_resp,
    aws_api_gateway_integration_response.event_options_int_resp
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.subscribe.id,
      aws_api_gateway_method.sub_post.id,
      aws_api_gateway_integration.sub_lambda_int.id,
      aws_api_gateway_method.sub_options.id,
      aws_api_gateway_integration.sub_options_int.id,
      aws_api_gateway_resource.create_event.id,
      aws_api_gateway_method.event_post.id,
      aws_api_gateway_integration.event_lambda_int.id,
      aws_api_gateway_method.event_options.id,
      aws_api_gateway_integration.event_options_int.id,
      aws_api_gateway_integration_response.sub_options_int_resp.id,
      aws_api_gateway_integration_response.event_options_int_resp.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# The "Prod" Stage
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.event_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.event_api.id
  stage_name    = "prod"

  # Prevents Terraform from destroying the stage before the new one is ready
  lifecycle {
    create_before_destroy = true
  }
}

// Give Lambdas necessary permissions to interact with SNS & S3
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
        Action   = ["s3:GetObject", "s3:PutObject"],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.website.arn}/*"
      },
      {
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Effect = "Allow",
        Resource = [
          "${aws_cloudwatch_log_group.sub_logs.arn}:*",
          "${aws_cloudwatch_log_group.api_logs.arn}:*"
        ]
      }
    ]
  })
}

// Log Group for the API Gateway
resource "aws_cloudwatch_log_group" "api_logs" {
  # This matches the 'EventAnnouncementAPI' name in your error logs
  name              = "/aws/api-gateway/${aws_api_gateway_rest_api.event_api.name}"
  retention_in_days = 1
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

# Enable logging in your Stage
resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  stage_name  = aws_api_gateway_stage.prod.stage_name
  method_path = "*/*"

  depends_on = [aws_api_gateway_account.settings]

  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}

# Create the IAM Role for API Gateway
resource "aws_iam_role" "api_gateway_logs" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "apigateway.amazonaws.com" }
    }]
  })
}

# Attach the standard AWS policy for API Gateway logging
resource "aws_iam_role_policy_attachment" "api_gateway_logs" {
  role       = aws_iam_role.api_gateway_logs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# SET THE GLOBAL ACCOUNT SETTING (The missing piece)
resource "aws_api_gateway_account" "settings" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_logs.arn
  reset_on_delete     = true
}