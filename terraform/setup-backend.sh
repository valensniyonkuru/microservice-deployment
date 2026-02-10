#!/bin/bash
# Setup Terraform S3 Backend with DynamoDB Locking

set -e

# Configuration
REGION="us-east-1"
BUCKET_NAME="lib-mgmt-terraform-state-${RANDOM}"
DYNAMODB_TABLE="lib-mgmt-terraform-locks"

echo "=========================================="
echo "Terraform Backend Setup"
echo "=========================================="
echo ""
echo "Region: $REGION"
echo "S3 Bucket: $BUCKET_NAME"
echo "DynamoDB Table: $DYNAMODB_TABLE"
echo ""

# Create S3 bucket for Terraform state
echo "Creating S3 bucket..."
aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $REGION 2>/dev/null || echo "Bucket might already exist"

# Enable versioning on the bucket
echo "Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled \
  --region $REGION

# Enable encryption
echo "Enabling encryption..."
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }' \
  --region $REGION

# Block public access
echo "Blocking public access..."
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
    BlockPublicAcls=true,\
    IgnorePublicAcls=true,\
    BlockPublicPolicy=true,\
    RestrictPublicBuckets=true \
  --region $REGION

# Create DynamoDB table for state locking
echo "Creating DynamoDB table for state locking..."
aws dynamodb create-table \
  --table-name $DYNAMODB_TABLE \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION 2>/dev/null || echo "Table might already exist"

# Wait for table to be active
echo "Waiting for DynamoDB table to be ready..."
aws dynamodb wait table-exists \
  --table-name $DYNAMODB_TABLE \
  --region $REGION

echo ""
echo "=========================================="
echo "✓ Backend Setup Complete!"
echo "=========================================="
echo ""
echo "S3 Bucket: $BUCKET_NAME"
echo "DynamoDB Table: $DYNAMODB_TABLE"
echo "Region: $REGION"
echo ""
echo "Next steps:"
echo "1. Update terraform/backend.tf with these values"
echo "2. Run: cd terraform && terraform init -migrate-state"
echo ""

# Save configuration to file
cat > backend-config.txt << EOF
bucket         = "$BUCKET_NAME"
key            = "production/terraform.tfstate"
region         = "$REGION"
encrypt        = true
dynamodb_table = "$DYNAMODB_TABLE"
EOF

echo "Backend configuration saved to backend-config.txt"
