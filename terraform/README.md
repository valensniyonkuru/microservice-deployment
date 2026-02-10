# AWS ECS Fargate Infrastructure for Library Management Microservices

This Terraform configuration deploys a complete microservices architecture on AWS ECS Fargate.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Cloud                                │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                      VPC (10.0.0.0/16)                     │ │
│  │                                                             │ │
│  │  ┌──────────────────┐         ┌──────────────────┐        │ │
│  │  │  Public Subnet   │         │  Public Subnet   │        │ │
│  │  │   (us-east-1a)   │         │   (us-east-1b)   │        │ │
│  │  │                  │         │                  │        │ │
│  │  │  ┌────────────┐  │         │  ┌────────────┐  │        │ │
│  │  │  │    ALB     │◄─┼─────────┼─►│   NAT GW   │  │        │ │
│  │  │  └────────────┘  │         │  └────────────┘  │        │ │
│  │  └──────────────────┘         └──────────────────┘        │ │
│  │           │                            │                   │ │
│  │  ┌────────▼──────────┐        ┌───────▼──────────┐        │ │
│  │  │  Private Subnet   │        │  Private Subnet  │        │ │
│  │  │   (us-east-1a)    │        │   (us-east-1b)   │        │ │
│  │  │                   │        │                  │        │ │
│  │  │  ┌─────────────┐  │        │  ┌─────────────┐│        │ │
│  │  │  │ECS Services │  │        │  │ECS Services ││        │ │
│  │  │  │  - Books    │  │        │  │  - Books    ││        │ │
│  │  │  │  - Customers│  │        │  │  - Customers││        │ │
│  │  │  │  - Orders   │  │        │  │  - Orders   ││        │ │
│  │  │  └─────────────┘  │        │  └─────────────┘│        │ │
│  │  │         │          │        │         │       │        │ │
│  │  │         └──────────┼────────┼─────────┘       │        │ │
│  │  │                    │        │                 │        │ │
│  │  │  ┌─────────────┐   │        │  ┌───────────┐ │        │ │
│  │  │  │     RDS     │   │        │  │Amazon MQ  │ │        │ │
│  │  │  │ (PostgreSQL)│   │        │  │(RabbitMQ) │ │        │ │
│  │  │  └─────────────┘   │        │  └───────────┘ │        │ │
│  │  └───────────────────┘         └─────────────────┘        │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Infrastructure Components

### Networking
- **VPC**: Custom VPC with public and private subnets across 2 availability zones
- **NAT Gateways**: For outbound internet access from private subnets
- **Security Groups**: Restricted access between components

### Compute
- **ECS Fargate**: Serverless container orchestration
- **Auto Scaling**: CPU and memory-based scaling policies
- **Application Load Balancer**: Routes traffic to microservices

### Data & Messaging
- **RDS PostgreSQL**: Managed relational database
- **Amazon MQ (RabbitMQ)**: Managed message broker

### Storage & Monitoring
- **ECR**: Container image registry
- **CloudWatch**: Logs and metrics
- **Container Insights**: ECS monitoring

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Terraform** >= 1.0 installed
4. **Docker** for building images
5. **Git** for version control

## Quick Start

### 1. Clone and Navigate

```bash
cd terraform
```

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update:
- `database_password` - Strong password for RDS
- `rabbitmq_password` - Strong password for RabbitMQ
- `jwt_secret` - Secure JWT secret
- `aws_region` - Your preferred AWS region

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Plan

```bash
terraform plan
```

### 5. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. Deployment takes approximately 10-15 minutes.

### 6. Get Outputs

```bash
terraform output
```

Save the outputs, especially:
- `alb_dns_name` - Your application URL
- `ecr_repository_urls` - For pushing Docker images

## Building and Deploying Services

### 1. Build Docker Images

From the project root:

```bash
# Build books service
docker build -t library-books:latest ./services/books

# Build customers service
docker build -t library-customers:latest ./services/customers

# Build orders service
docker build -t library-orders:latest ./services/orders
```

### 2. Push to ECR

Get ECR login credentials:

```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

Tag and push images:

```bash
# Get ECR URLs from Terraform outputs
BOOKS_ECR=$(terraform output -raw ecr_repository_urls | jq -r '.books')
CUSTOMERS_ECR=$(terraform output -raw ecr_repository_urls | jq -r '.customers')
ORDERS_ECR=$(terraform output -raw ecr_repository_urls | jq -r '.orders')

# Tag images
docker tag library-books:latest $BOOKS_ECR:latest
docker tag library-customers:latest $CUSTOMERS_ECR:latest
docker tag library-orders:latest $ORDERS_ECR:latest

# Push images
docker push $BOOKS_ECR:latest
docker push $CUSTOMERS_ECR:latest
docker push $ORDERS_ECR:latest
```

### 3. Update ECS Services

```bash
# Force new deployment
aws ecs update-service --cluster <cluster-name> --service books --force-new-deployment
aws ecs update-service --cluster <cluster-name> --service customers --force-new-deployment
aws ecs update-service --cluster <cluster-name> --service orders --force-new-deployment
```

Or use the deployment script:

```bash
../scripts/deploy.sh
```

## Accessing Services

After deployment, services are available through the ALB:

```bash
# Get ALB DNS
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test endpoints
curl http://$ALB_DNS/books/health
curl http://$ALB_DNS/customers/health
curl http://$ALB_DNS/orders/health
```

## Monitoring

### CloudWatch Logs

```bash
# View logs
aws logs tail /ecs/library-management-dev/books --follow
aws logs tail /ecs/library-management-dev/customers --follow
aws logs tail /ecs/library-management-dev/orders --follow
```

### ECS Service Status

```bash
# Check service status
aws ecs describe-services --cluster <cluster-name> --services books customers orders
```

### Container Insights

Access Container Insights in AWS Console:
1. Go to CloudWatch → Container Insights
2. Select your ECS cluster
3. View performance metrics

## Scaling

### Manual Scaling

```bash
# Update desired count
aws ecs update-service --cluster <cluster-name> --service books --desired-count 4
```

### Auto Scaling

Auto scaling is enabled by default based on:
- **CPU**: Scales when average CPU > 70%
- **Memory**: Scales when average memory > 80%

Configure in `terraform.tfvars`:

```hcl
autoscaling_target_cpu    = 70
autoscaling_target_memory = 80

ecs_service_min_count = {
  books     = 1
  customers = 1
  orders    = 1
}

ecs_service_max_count = {
  books     = 10
  customers = 10
  orders    = 10
}
```

## Cost Optimization

### Development Environment

For lower costs in development:

```hcl
# terraform.tfvars
db_instance_class = "db.t3.micro"
db_multi_az       = false
mq_instance_type  = "mq.t3.micro"

ecs_task_cpu = {
  books     = "256"
  customers = "256"
  orders    = "256"
}

ecs_task_memory = {
  books     = "512"
  customers = "512"
  orders    = "512"
}

ecs_service_desired_count = {
  books     = 1
  customers = 1
  orders    = 1
}
```

### Production Environment

For production resilience:

```hcl
# terraform.tfvars
db_instance_class = "db.t3.medium"
db_multi_az       = true
mq_instance_type  = "mq.m5.large"

ecs_service_desired_count = {
  books     = 3
  customers = 3
  orders    = 3
}
```

## Environment Management

### Multiple Environments

Create workspace for each environment:

```bash
# Development
terraform workspace new dev
terraform workspace select dev
terraform apply -var-file="environments/dev.tfvars"

# Staging
terraform workspace new staging
terraform workspace select staging
terraform apply -var-file="environments/staging.tfvars"

# Production
terraform workspace new prod
terraform workspace select prod
terraform apply -var-file="environments/prod.tfvars"
```

### Remote State (Recommended)

Configure S3 backend for team collaboration:

```hcl
# main.tf
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "library-management/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

Create S3 bucket and DynamoDB table:

```bash
aws s3 mb s3://your-terraform-state-bucket
aws s3api put-bucket-versioning --bucket your-terraform-state-bucket --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

## Troubleshooting

### ECS Tasks Failing to Start

1. Check CloudWatch logs
2. Verify environment variables in task definition
3. Ensure security groups allow traffic
4. Check RDS and MQ connectivity

### Database Connection Issues

```bash
# Test from ECS task
aws ecs execute-command \
  --cluster <cluster-name> \
  --task <task-id> \
  --container books \
  --interactive \
  --command "sh"

# Inside container
nc -zv <rds-endpoint> 5432
```

### High Costs

1. Review CloudWatch billing alarms
2. Check NAT Gateway data transfer
3. Review RDS instance size
4. Monitor ECS task count
5. Enable Fargate Spot for non-production

## Security Best Practices

1. **Secrets Management**: Use AWS Secrets Manager (not implemented in v1)
2. **Database**: Enable encryption at rest and in transit
3. **Network**: Keep services in private subnets
4. **IAM**: Follow least privilege principle
5. **HTTPS**: Add ACM certificate for production
6. **Monitoring**: Enable GuardDuty and Security Hub

## Updating Infrastructure

```bash
# Make changes to .tf files
# Review changes
terraform plan

# Apply changes
terraform apply

# For specific resources
terraform apply -target=module.ecs_services
```

## Destroying Infrastructure

**Warning**: This will delete all resources including databases!

```bash
# Review what will be deleted
terraform plan -destroy

# Destroy everything
terraform destroy
```

For production, consider:
1. Taking RDS snapshots
2. Backing up S3 data
3. Exporting CloudWatch logs

## Module Structure

```
terraform/
├── main.tf                 # Root module
├── variables.tf           # Input variables
├── outputs.tf             # Output values
├── terraform.tfvars       # Variable values (don't commit!)
└── modules/
    ├── vpc/               # VPC and networking
    ├── security/          # Security groups
    ├── ecr/               # Container registry
    ├── rds/               # PostgreSQL database
    ├── mq/                # RabbitMQ broker
    ├── alb/               # Load balancer
    ├── ecs-cluster/       # ECS cluster and IAM
    └── ecs-services/      # ECS services and tasks
```

## Variables Reference

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `us-east-1` |
| `environment` | Environment name | `dev` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `db_instance_class` | RDS instance class | `db.t3.micro` |
| `mq_instance_type` | Amazon MQ instance type | `mq.t3.micro` |
| `ecs_task_cpu` | CPU units per service | `256` |
| `ecs_task_memory` | Memory per service (MB) | `512` |

See `variables.tf` for complete list.

## Outputs Reference

| Output | Description |
|--------|-------------|
| `alb_dns_name` | Load balancer DNS name |
| `ecr_repository_urls` | ECR repository URLs |
| `rds_endpoint` | Database endpoint |
| `ecs_cluster_name` | ECS cluster name |

See `outputs.tf` for complete list.

## CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Deploy to ECS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Build and push Docker images
        run: |
          ./scripts/build-and-push.sh
      
      - name: Deploy to ECS
        run: |
          ./scripts/deploy.sh
```

## Support

For issues or questions:
1. Check CloudWatch logs
2. Review AWS Console
3. Verify Terraform state
4. Check security group rules

## License

[Your License Here]
