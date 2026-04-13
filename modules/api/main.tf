# Create the REST API
resource "aws_api_gateway_rest_api" "event_api" {
  name        = "EventAnnouncementAPI"
  description = "API for Event Subscriptions and Creation"
}

# SUBSCRIBE ENDPOINT
resource "aws_api_gateway_resource" "subscribe" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  parent_id   = aws_api_gateway_rest_api.event_api.root_resource_id
  path_part   = "subscribe"
}

# The actual POST method for subscribing
resource "aws_api_gateway_method" "sub_post" {
  rest_api_id   = aws_api_gateway_rest_api.event_api.id
  resource_id   = aws_api_gateway_resource.subscribe.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integrate the POST method with your Subscribe Lambda
resource "aws_api_gateway_integration" "sub_lambda_int" {
  rest_api_id             = aws_api_gateway_rest_api.event_api.id
  resource_id             = aws_api_gateway_resource.subscribe.id
  http_method             = aws_api_gateway_method.sub_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY" # Use PROXY so Lambda can send headers
  uri                     = var.subscribe_lambda_arn
}

# Give API Gateway permission to call this Lambda
resource "aws_lambda_permission" "apigw_sub" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.subscribe_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.event_api.execution_arn}/*/*"
}

# OPTIONS method for CORS preflight
resource "aws_api_gateway_method" "sub_options" {
  rest_api_id   = aws_api_gateway_rest_api.event_api.id
  resource_id   = aws_api_gateway_resource.subscribe.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Define the Method Response
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

# Ensure Integer Status Code in Mock Integration
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

# Verify Integration Response
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

# CREATE-EVENT ENDPOINT
resource "aws_api_gateway_resource" "create_event" {
  rest_api_id = aws_api_gateway_rest_api.event_api.id
  parent_id   = aws_api_gateway_rest_api.event_api.root_resource_id
  path_part   = "create-event"
}

# The actual POST method for creating events
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
  uri                     = var.create_lambda_arn
}

# Permission for API Gateway to call Create Event Lambda
resource "aws_lambda_permission" "apigw_event" {
  statement_id  = "AllowAPIGatewayInvokeEvent"
  action        = "lambda:InvokeFunction"
  function_name = var.create_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.event_api.execution_arn}/*/*"
}

# OPTIONS method for CORS preflight on Create Event
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

# Mock Integration for OPTIONS
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

# IAM Role Policy for API Gateway to write logs to CloudWatch
resource "aws_iam_role_policy" "lambda_permissions" {
  name = "event_project_policy"
  role = var.lambda_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Effect = "Allow",
        Resource = [
          "${aws_cloudwatch_log_group.api_logs.arn}:*"
        ]
      }
    ]
  })
}

# Log Group for the API Gateway
resource "aws_cloudwatch_log_group" "api_logs" {
  # This matches the 'EventAnnouncementAPI' name in your error logs
  name              = "/aws/api-gateway/${aws_api_gateway_rest_api.event_api.name}"
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
