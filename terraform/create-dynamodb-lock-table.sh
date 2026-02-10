#!/bin/bash
# Create only the DynamoDB lock table (e.g. if backend was set up but table is missing in this region)

set -e
REGION="${AWS_REGION:-eu-north-1}"
TABLE="lib-mgmt-terraform-locks"

echo "Creating DynamoDB table '$TABLE' in $REGION..."
aws dynamodb create-table \
  --table-name "$TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" 2>/dev/null && echo "Table created." || echo "Table may already exist."

aws dynamodb wait table-exists --table-name "$TABLE" --region "$REGION"
echo "Done. Run: terraform init -reconfigure && terraform apply -auto-approve"
