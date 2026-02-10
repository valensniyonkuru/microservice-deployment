# Library Management Microservices

Production-ready microservices for library management, deployed on AWS ECS Fargate.

## Architecture

```
Internet → ALB → ECS Services (Books, Customers, Orders)
                      ↓
               RDS + RabbitMQ
```

## Services

- **Books** (port 3000): Book inventory management
- **Customers** (port 3001): User authentication & management
- **Orders** (port 3002): Order processing

## Quick Start

### Prerequisites

- AWS Account with credentials
- GitHub repository
- Docker (for local testing)

### Setup

1. **Configure GitHub Secrets**

   Go to Settings → Secrets → Actions and add:
   ```
   AWS_ACCESS_KEY_ID
   AWS_SECRET_ACCESS_KEY
   DATABASE_PASSWORD
   RABBITMQ_PASSWORD
   JWT_SECRET
   ```

2. **Configure Terraform**

   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars as needed
   ```

3. **Deploy**

   Push to main branch:
   ```bash
   git push origin main
   ```

   Or manually trigger via GitHub Actions.

## Deployment Pipeline

The pipeline automatically:
1. Builds Docker images
2. Pushes to Amazon ECR
3. Deploys infrastructure with Terraform
4. Updates ECS services
5. Verifies health

View progress: GitHub → Actions → Deploy to Production

## Local Development

```bash
# Start services
docker-compose up

# Access services
curl http://localhost:3000/books
curl http://localhost:3001/customers
curl http://localhost:3002/orders
```

## Monitoring

```bash
# Check service health
make health

# View service status
make status

# Scale services
make scale-books COUNT=4
```

## Infrastructure

- **Compute**: ECS Fargate
- **Database**: RDS PostgreSQL
- **Message Queue**: Amazon MQ (RabbitMQ)
- **Load Balancer**: Application Load Balancer
- **Networking**: VPC with public/private subnets
- **Container Registry**: Amazon ECR

## Costs

Estimated monthly cost: **$50-100**
- ECS Fargate: ~$20
- RDS: ~$15
- Amazon MQ: ~$10
- NAT Gateway: ~$30
- ALB: ~$20

## Management

```bash
# Check infrastructure
make info

# Destroy infrastructure
# GitHub → Actions → Deploy to Production → Run workflow → destroy
```

## Documentation

- [PIPELINE.md](PIPELINE.md) - CI/CD pipeline details
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment guide
- [CHANGES.md](CHANGES.md) - Change history

## Support

Check GitHub Actions logs for deployment issues.
