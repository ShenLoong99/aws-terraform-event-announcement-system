output "api_url" {
  description = "The URL to put into your frontend code"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "api_key" {
  description = "The API key for the API Gateway"
  value       = aws_api_gateway_api_key.my_key.value
}

output "api_logs_arn" {
  description = "The ARN of the CloudWatch Log Group for API Gateway logs"
  value       = aws_cloudwatch_log_group.api_logs.arn
}
