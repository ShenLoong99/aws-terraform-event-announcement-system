# S3 Bucket (Frontend)
resource "aws_s3_bucket" "website" {
  # Generates a name like: event-announcement-8a2f1b3c
  bucket = "event-announcement-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "Event-Frontend-Storage"
  }
}

# Protects your events.json from accidental deletion/corruption
resource "aws_s3_bucket_versioning" "website_versioning" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Generate a random suffix for the bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.website.id
  index_document { suffix = "index.html" }
}

// S3 Bucket Public Access Configuration
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.website.id

  # These must be FALSE to allow the public bucket policy
  block_public_acls       = true  # Best Practice: Use Policies, not ACLs
  block_public_policy     = false # Must be false to allow your website policy
  ignore_public_acls      = true
  restrict_public_buckets = false # Must be false for public website access
}

// S3 Bucket Policy
resource "aws_s3_bucket_policy" "allow_public" {
  bucket = aws_s3_bucket.website.id

  # CRITICAL: Wait for the access blocks to be removed first
  depends_on = [aws_s3_bucket_public_access_block.public]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.website.arn}/*"
    }]
  })
}

# Upload index.html
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  content_type = "text/html"

  # Use content instead of source for templates
  content = templatefile("${path.module}/frontend/index.html.tftpl", {
    api_url = var.api_invoke_url
  })

  # Use md5() on the content string since the physical .html file doesn't exist yet
  etag = md5(templatefile("${path.module}/frontend/index.html.tftpl", {
    api_url = var.api_invoke_url
  }))

  # Wait for the bucket and its website/policy config to be READY
  depends_on = [
    aws_s3_bucket_website_configuration.hosting,
    aws_s3_bucket_policy.allow_public
  ]
}

# Upload style.css
resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.website.id
  key          = "style.css"
  source       = "${path.module}/frontend/style.css"
  content_type = "text/css"

  # Added: Ensures Terraform and S3 track the file hash correctly
  etag = filemd5("${path.module}/frontend/style.css")

  # Wait for the bucket and its website/policy config to be READY
  depends_on = [
    aws_s3_bucket_website_configuration.hosting,
    aws_s3_bucket_policy.allow_public
  ]
}

# Upload initial events.json
resource "aws_s3_object" "data" {
  bucket       = aws_s3_bucket.website.id
  key          = "events.json"
  source       = "${path.module}/frontend/events.json"
  content_type = "application/json"

  # Added: Ensures Terraform and S3 track the file hash correctly
  etag = filemd5("${path.module}/frontend/events.json")

  # Wait for the bucket and its website/policy config to be READY
  depends_on = [
    aws_s3_bucket_website_configuration.hosting,
    aws_s3_bucket_policy.allow_public
  ]
}

resource "aws_iam_role_policy" "lambda_permissions" {
  name = "event_project_policy"
  role = var.lambda_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:PutObject"],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}
