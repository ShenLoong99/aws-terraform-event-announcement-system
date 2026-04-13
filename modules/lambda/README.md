<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.event_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.sub_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.create_event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.subscribe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_sns_topic.event_updates](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sqs_queue.lambda_dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [archive_file.event_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.sub_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_id"></a> [bucket\_id](#input\_bucket\_id) | The ID of the S3 bucket created for hosting the website | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_create_lambda_arn"></a> [create\_lambda\_arn](#output\_create\_lambda\_arn) | The ARN of the Create Event Lambda function |
| <a name="output_create_lambda_name"></a> [create\_lambda\_name](#output\_create\_lambda\_name) | The name of the Create Event Lambda function |
| <a name="output_lambda_role_id"></a> [lambda\_role\_id](#output\_lambda\_role\_id) | The ID of the IAM role used by the Lambda functions |
| <a name="output_subscribe_lambda_arn"></a> [subscribe\_lambda\_arn](#output\_subscribe\_lambda\_arn) | The ARN of the Subscribe Lambda function |
| <a name="output_subscribe_lambda_name"></a> [subscribe\_lambda\_name](#output\_subscribe\_lambda\_name) | The name of the Subscribe Lambda function |
<!-- END_TF_DOCS -->