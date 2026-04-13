# This Terraform configuration sets up a serverless event announcement system using AWS services. It includes:

# modules/lambda: Defines two Lambda functions (Subscribe and Create Event) and packages their code.
module "lambda" {
  source       = "./modules/lambda"
  bucket_id    = module.storage.bucket_id
  api_logs_arn = module.api.api_logs_arn
  bucket_arn   = module.storage.bucket_arn
}

# modules/storage: Creates an S3 bucket to host the frontend website and uploads necessary files.
module "storage" {
  source  = "./modules/storage"
  api_url = module.api.api_url
  api_key = module.api.api_key
}

# modules/api: Sets up an API Gateway REST API with endpoints that integrate with the Lambda functions.
module "api" {
  source                = "./modules/api"
  subscribe_lambda_arn  = module.lambda.subscribe_lambda_arn
  subscribe_lambda_name = module.lambda.subscribe_lambda_name
  create_lambda_arn     = module.lambda.create_lambda_arn
  create_lambda_name    = module.lambda.create_lambda_name
}
