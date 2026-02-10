# Terraform Backend Configuration
# Run setup-backend.sh first to create the S3 bucket and DynamoDB table

terraform {
  backend "s3" {
    # Update these values after running setup-backend.sh
    bucket         = "lib-mgmt-terraform-state-13525"
    key            = "production/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "lib-mgmt-terraform-locks"
  }
}
