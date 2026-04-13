output "bucket_id" {
  description = "The ID of the S3 bucket created for hosting the website"
  value       = aws_s3_bucket.website.id
}

output "website_url" {
  description = "The URL of the hosted website"
  value       = "http://${aws_s3_bucket_website_configuration.hosting.website_endpoint}"
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket used for hosting the website"
  value       = aws_s3_bucket.website.arn
}
