terraform {
  backend "s3" {
    bucket         = "goit-devops-tf-state"
    key            = "infra/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "goit-devops-tf-locks"
    encrypt        = true
  }
}

# Bootstrap note:
# Create the S3 bucket and DynamoDB table first (using the s3-backend module
# in a temporary local-state run, or manually), then replace the placeholders
# above and run `terraform init -reconfigure`.
