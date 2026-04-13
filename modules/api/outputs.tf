output "api_url" {
  description = "The URL to put into your frontend code"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "api_invoke_url" {
  description = "The invoke URL of the API Gateway"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "api_key" {
  description = "The API key for the API Gateway"
  value       = aws_api_gateway_api_key.my_key.value
}
