variable "lambda_role_id" {
  description = "The ID of the IAM role used by the Lambda functions"
  type        = string
}

variable "api_invoke_url" {
  description = "The invoke URL of the API Gateway"
  type        = string
}
