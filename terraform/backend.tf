# Terraform Backend Configuration
# Run setup-backend.sh first to create the S3 bucket and DynamoDB table

terraform {
  backend "s3" {
    # Update these values after running setup-backend.sh
    bucket         = "lib-mgmt-tf-state-1770742750"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "lib-mgmt-terraform-locks"
  }
}
