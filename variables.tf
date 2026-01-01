variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "bucket_name" {
  description = "Unique name for your S3 bucket"
  type        = string
  default     = "event-announcement-site-2025-unique"
}

variable "environment" {
  description = "Set to 'local' for dev or 'prod' for showcase"
  type        = string
  default     = "local"
}