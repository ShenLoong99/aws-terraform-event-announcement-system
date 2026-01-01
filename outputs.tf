output "website_url" {
  value = "http://${aws_s3_bucket_website_configuration.hosting.website_endpoint}"
}

output "api_url" {
  description = "The URL to put into your frontend code"
  value       = aws_api_gateway_stage.prod.invoke_url
}