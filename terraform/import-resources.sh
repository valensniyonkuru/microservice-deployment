#!/bin/bash
# Import existing AWS resources into Terraform state

set -e

echo "Importing existing resources into Terraform state..."

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="eu-north-1"
ENV="production"

cd terraform
terraform init

# Import ECR Repositories
echo "Importing ECR repositories..."
terraform import 'module.ecr.aws_ecr_repository.services["books"]' "lib-mgmt-${ENV}-books" || true
terraform import 'module.ecr.aws_ecr_repository.services["customers"]' "lib-mgmt-${ENV}-customers" || true
terraform import 'module.ecr.aws_ecr_repository.services["orders"]' "lib-mgmt-${ENV}-orders" || true

# Import Load Balancer
echo "Importing ALB..."
ALB_ARN=$(aws elbv2 describe-load-balancers --names "lib-mgmt-${ENV}-alb" --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>/dev/null || echo "")
if [ -n "$ALB_ARN" ]; then
  terraform import 'module.alb.aws_lb.main' "$ALB_ARN" || true
fi

# Import Target Groups
echo "Importing Target Groups..."
TG_BOOKS=$(aws elbv2 describe-target-groups --names "lib-mgmt-${ENV}-books" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "")
TG_CUST=$(aws elbv2 describe-target-groups --names "lib-mgmt-${ENV}-cust" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "")
TG_ORDERS=$(aws elbv2 describe-target-groups --names "lib-mgmt-${ENV}-orders" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "")

[ -n "$TG_BOOKS" ] && terraform import 'module.alb.aws_lb_target_group.books' "$TG_BOOKS" || true
[ -n "$TG_CUST" ] && terraform import 'module.alb.aws_lb_target_group.customers' "$TG_CUST" || true
[ -n "$TG_ORDERS" ] && terraform import 'module.alb.aws_lb_target_group.orders' "$TG_ORDERS" || true

# Import MQ Broker
echo "Importing Amazon MQ..."
terraform import 'module.mq.aws_mq_broker.main' "lib-mgmt-${ENV}-mq" || true

# Import RDS Subnet Group
echo "Importing RDS subnet group..."
terraform import 'module.rds.aws_db_subnet_group.main' "lib-mgmt-${ENV}-db-subnet" || true

echo "Import complete! Now run: terraform apply"
