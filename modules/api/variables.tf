variable "subscribe_lambda_arn" {
  description = "The ARN of the Subscribe Lambda function"
  type        = string
}

variable "subscribe_lambda_name" {
  description = "The name of the Subscribe Lambda function"
  type        = string
}

variable "create_lambda_arn" {
  description = "The ARN of the Create Event Lambda function"
  type        = string
}

variable "create_lambda_name" {
  description = "The name of the Create Event Lambda function"
  type        = string
}
