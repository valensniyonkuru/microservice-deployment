terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "LibraryManagement"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  services     = var.services
}

# RDS PostgreSQL Module
module "rds" {
  source = "./modules/rds"

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  security_group_id      = module.security_groups.rds_security_group_id
  database_name          = var.database_name
  database_username      = var.database_username
  database_password      = var.database_password
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  multi_az               = var.db_multi_az
}

# Amazon MQ (RabbitMQ) Module
module "mq" {
  source = "./modules/mq"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  security_group_id     = module.security_groups.mq_security_group_id
  rabbitmq_username     = var.rabbitmq_username
  rabbitmq_password     = var.rabbitmq_password
  instance_type         = var.mq_instance_type
}

# Application Load Balancer Module
module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_id  = module.security_groups.alb_security_group_id
  certificate_arn    = var.certificate_arn
}

# ECS Cluster Module
module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  project_name = var.project_name
  environment  = var.environment
}

# ECS Services Module
module "ecs_services" {
  source = "./modules/ecs-services"

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  ecs_cluster_id         = module.ecs_cluster.cluster_id
  ecs_cluster_name       = module.ecs_cluster.cluster_name
  execution_role_arn     = module.ecs_cluster.execution_role_arn
  task_role_arn          = module.ecs_cluster.task_role_arn
  
  # Service configurations
  services               = var.services
  
  # Load balancer
  alb_target_group_books_arn      = module.alb.target_group_books_arn
  alb_target_group_customers_arn  = module.alb.target_group_customers_arn
  alb_target_group_orders_arn     = module.alb.target_group_orders_arn
  
  # Security groups
  ecs_security_group_id  = module.security_groups.ecs_security_group_id
  
  # Database and MQ
  database_endpoint      = module.rds.endpoint
  database_name          = var.database_name
  database_username      = var.database_username
  database_password      = var.database_password
  rabbitmq_endpoint      = module.mq.endpoint
  rabbitmq_username      = var.rabbitmq_username
  rabbitmq_password      = var.rabbitmq_password
  
  # JWT secret
  jwt_secret             = var.jwt_secret
  
  # ECR repositories
  ecr_repository_urls    = module.ecr.repository_urls
}
