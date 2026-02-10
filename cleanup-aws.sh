#!/bin/bash
# Delete existing AWS resources that are causing conflicts

set -e

ENV="production"
REGION="eu-north-1"

echo "Cleaning up existing AWS resources..."

# Delete ECR Repositories
echo "Deleting ECR repositories..."
aws ecr delete-repository --repository-name "lib-mgmt-${ENV}-books" --force --region $REGION 2>/dev/null || echo "  - books repo not found"
aws ecr delete-repository --repository-name "lib-mgmt-${ENV}-customers" --force --region $REGION 2>/dev/null || echo "  - customers repo not found"
aws ecr delete-repository --repository-name "lib-mgmt-${ENV}-orders" --force --region $REGION 2>/dev/null || echo "  - orders repo not found"

# Delete Target Groups
echo "Deleting Target Groups..."
TG_BOOKS=$(aws elbv2 describe-target-groups --names "lib-mgmt-${ENV}-books" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "")
TG_CUST=$(aws elbv2 describe-target-groups --names "lib-mgmt-${ENV}-cust" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "")
TG_ORDERS=$(aws elbv2 describe-target-groups --names "lib-mgmt-${ENV}-orders" --query 'TargetGroups[0].TargetGroupArn' --output text 2>/dev/null || echo "")

[ -n "$TG_BOOKS" ] && aws elbv2 delete-target-group --target-group-arn "$TG_BOOKS" 2>/dev/null || echo "  - books TG not found"
[ -n "$TG_CUST" ] && aws elbv2 delete-target-group --target-group-arn "$TG_CUST" 2>/dev/null || echo "  - customers TG not found"
[ -n "$TG_ORDERS" ] && aws elbv2 delete-target-group --target-group-arn "$TG_ORDERS" 2>/dev/null || echo "  - orders TG not found"

# Delete Load Balancer
echo "Deleting ALB..."
ALB_ARN=$(aws elbv2 describe-load-balancers --names "lib-mgmt-${ENV}-alb" --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>/dev/null || echo "")
[ -n "$ALB_ARN" ] && aws elbv2 delete-load-balancer --load-balancer-arn "$ALB_ARN" 2>/dev/null || echo "  - ALB not found"

# Wait for ALB deletion
if [ -n "$ALB_ARN" ]; then
  echo "Waiting for ALB deletion..."
  sleep 60
fi

# Delete RDS Subnet Group
echo "Deleting RDS subnet group..."
aws rds delete-db-subnet-group --db-subnet-group-name "lib-mgmt-${ENV}-db-subnet" --region $REGION 2>/dev/null || echo "  - DB subnet group not found"

# Delete MQ Broker
echo "Deleting Amazon MQ broker..."
MQ_ID=$(aws mq list-brokers --query "BrokerSummaries[?BrokerName=='lib-mgmt-${ENV}-mq'].BrokerId" --output text 2>/dev/null || echo "")
[ -n "$MQ_ID" ] && aws mq delete-broker --broker-id "$MQ_ID" 2>/dev/null || echo "  - MQ broker not found"

echo ""
echo "✓ Cleanup complete!"
echo ""
echo "Now you can run the pipeline again."
echo "The resources will be created fresh by Terraform."
