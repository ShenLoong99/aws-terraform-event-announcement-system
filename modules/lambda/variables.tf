variable "bucket_id" {
  description = "The ID of the S3 bucket created for hosting the website"
  type        = string
}

variable "api_logs_arn" {
  description = "The ARN of the CloudWatch Logs group for API Gateway access logs"
  type        = string
}

variable "bucket_arn" {
  description = "The ARN of the S3 bucket for Lambda access"
  type        = string
}
