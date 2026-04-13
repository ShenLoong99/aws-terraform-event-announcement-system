output "subscribe_lambda_arn" {
  description = "The ARN of the Subscribe Lambda function"
  value       = aws_lambda_function.subscribe.invoke_arn
}

output "subscribe_lambda_name" {
  description = "The name of the Subscribe Lambda function"
  value       = aws_lambda_function.subscribe.function_name
}

output "create_lambda_arn" {
  description = "The ARN of the Create Event Lambda function"
  value       = aws_lambda_function.create_event.invoke_arn
}

output "create_lambda_name" {
  description = "The name of the Create Event Lambda function"
  value       = aws_lambda_function.create_event.function_name
}

output "lambda_role_id" {
  description = "The ID of the IAM role used by the Lambda functions"
  value       = aws_iam_role.lambda_role.id
}
