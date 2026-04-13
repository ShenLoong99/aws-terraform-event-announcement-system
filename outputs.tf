output "website_url" {
  description = "The URL of the hosted website"
  value       = module.storage.website_url
}

output "api_url" {
  description = "The URL to put into your frontend code"
  value       = module.api.api_url
}

output "aws_region" {
  description = "The AWS region where the resources are deployed"
  value       = var.aws_region
}
