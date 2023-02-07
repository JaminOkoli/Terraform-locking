# Goal of this project to write Terraform IaC to deploy Apache Webserver in AWS cloud.
# https://www.devopsrealtime.com/deploy-apache-web-server-using-terraform-iac/

provider "aws" {
  region = "us-east-1"
}


resource "aws_s3_bucket" "terraform-state-1100" {
  bucket = "terraform-state-1100"
  lifecycle {
    # prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform-state-1100.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform-state-1100.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform-state-1100.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_dynamodb_table" "terraform_locks_db_1100" {
  name         = "terraform_locks_db_1100"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket = "terraform-state-1100"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform_locks_db_1100"
    encrypt = true
 }
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform-state-1100.arn
  description = "S3 Bucket ARN"
}

output "dynamo_table_name" {
    value = aws_dynamodb_table.terraform_locks_db_1100.name
    description = "DynamoDB table name"
}