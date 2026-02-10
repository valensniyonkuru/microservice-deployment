# Project Structure

## Essential Files

```
library-management-microservices-rabbitmq-nestjs/
│
├── .github/workflows/
│   ├── deploy.yml              # CI/CD pipeline
│   └── README.md               # Pipeline documentation
│
├── services/                    # Microservices
│   ├── books/
│   │   ├── src/
│   │   ├── Dockerfile
│   │   └── package.json
│   ├── customers/
│   │   ├── src/
│   │   ├── Dockerfile
│   │   └── package.json
│   └── orders/
│       ├── src/
│       ├── Dockerfile
│       └── package.json
│
├── terraform/                   # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── modules/
│       ├── vpc/
│       ├── security/
│       ├── ecr/
│       ├── rds/
│       ├── mq/
│       ├── alb/
│       ├── ecs-cluster/
│       └── ecs-services/
│
├── docker-compose.yml           # Local development
├── .gitignore
├── Makefile                     # Helper commands
├── README.md                    # Main documentation
└── SETUP.md                     # Setup guide
```

## Key Components

### CI/CD Pipeline
- **Location**: `.github/workflows/deploy.yml`
- **Trigger**: Push to main or manual
- **Duration**: ~15-20 minutes
- **Stages**: Build → Infrastructure → Deploy → Verify

### Infrastructure
- **Tool**: Terraform
- **Resources**: ECS, RDS, Amazon MQ, ALB, VPC
- **Environment**: Production
- **Region**: us-east-1

### Services
- **Books**: Port 3000
- **Customers**: Port 3001
- **Orders**: Port 3002

## What Was Removed

- ❌ CloudWatch logging
- ❌ Shell scripts (build-and-push.sh, deploy.sh, etc.)
- ❌ Multiple CI/CD platforms (GitLab, Azure)
- ❌ Excessive documentation

## What Remains

- ✅ Production-focused pipeline
- ✅ Essential Terraform modules
- ✅ Core documentation
- ✅ Local development setup
- ✅ Simple Makefile commands

## Quick Commands

```bash
# Local development
docker-compose up

# Check infrastructure
make info

# Check health
make health

# View service status
make status
```

## Documentation

- `README.md` - Overview and quick start
- `SETUP.md` - Detailed setup instructions
- `.github/workflows/README.md` - Pipeline details
- `PROJECT_STRUCTURE.md` - This file

## Deployment Flow

```
Developer → Push to main → GitHub Actions → Build → Deploy → Verify → ✓
```

That's it! Simple and effective.
