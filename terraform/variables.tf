variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name to be used for resource naming"
  type        = string
  default     = "library-management"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# Services Configuration
variable "services" {
  description = "List of microservices"
  type        = list(string)
  default     = ["books", "customers", "orders"]
}

# Database Configuration
variable "database_name" {
  description = "Name of the RDS database"
  type        = string
  default     = "library_db"
}

variable "database_username" {
  description = "Username for RDS database"
  type        = string
  default     = "library_user"
  sensitive   = true
}

variable "database_password" {
  description = "Password for RDS database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 20
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = false
}

# RabbitMQ Configuration
variable "rabbitmq_username" {
  description = "Username for RabbitMQ"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "rabbitmq_password" {
  description = "Password for RabbitMQ"
  type        = string
  sensitive   = true
}

variable "mq_instance_type" {
  description = "Amazon MQ instance type"
  type        = string
  default     = "mq.t3.micro"
}

# JWT Configuration
variable "jwt_secret" {
  description = "JWT secret for customer service"
  type        = string
  sensitive   = true
}

# Load Balancer Configuration
variable "certificate_arn" {
  description = "ARN of ACM certificate for HTTPS (optional)"
  type        = string
  default     = ""
}

# ECS Configuration
variable "ecs_task_cpu" {
  description = "CPU units for ECS tasks"
  type        = map(string)
  default = {
    books     = "256"
    customers = "256"
    orders    = "256"
  }
}

variable "ecs_task_memory" {
  description = "Memory for ECS tasks in MB"
  type        = map(string)
  default = {
    books     = "512"
    customers = "512"
    orders    = "512"
  }
}

variable "ecs_service_desired_count" {
  description = "Desired number of ECS tasks per service"
  type        = map(number)
  default = {
    books     = 2
    customers = 2
    orders    = 2
  }
}

variable "ecs_service_min_count" {
  description = "Minimum number of ECS tasks per service (for autoscaling)"
  type        = map(number)
  default = {
    books     = 1
    customers = 1
    orders    = 1
  }
}

variable "ecs_service_max_count" {
  description = "Maximum number of ECS tasks per service (for autoscaling)"
  type        = map(number)
  default = {
    books     = 4
    customers = 4
    orders    = 4
  }
}

# Auto Scaling Configuration
variable "enable_autoscaling" {
  description = "Enable ECS service autoscaling"
  type        = bool
  default     = true
}

variable "autoscaling_target_cpu" {
  description = "Target CPU utilization for autoscaling"
  type        = number
  default     = 70
}

variable "autoscaling_target_memory" {
  description = "Target memory utilization for autoscaling"
  type        = number
  default     = 80
}
