variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "ecs_cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}

variable "services" {
  description = "List of microservices"
  type        = list(string)
}

variable "alb_target_group_books_arn" {
  description = "Books service target group ARN"
  type        = string
}

variable "alb_target_group_customers_arn" {
  description = "Customers service target group ARN"
  type        = string
}

variable "alb_target_group_orders_arn" {
  description = "Orders service target group ARN"
  type        = string
}

variable "ecs_security_group_id" {
  description = "ECS security group ID"
  type        = string
}

variable "database_endpoint" {
  description = "RDS endpoint"
  type        = string
}

variable "database_name" {
  description = "Database name"
  type        = string
}

variable "database_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "rabbitmq_endpoint" {
  description = "RabbitMQ endpoint"
  type        = string
}

variable "rabbitmq_username" {
  description = "RabbitMQ username"
  type        = string
  sensitive   = true
}

variable "rabbitmq_password" {
  description = "RabbitMQ password"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret for customer service"
  type        = string
  sensitive   = true
}

variable "ecr_repository_urls" {
  description = "ECR repository URLs"
  type        = map(string)
}

variable "ecs_task_cpu" {
  description = "CPU units for ECS tasks"
  type        = map(string)
  default     = {}
}

variable "ecs_task_memory" {
  description = "Memory for ECS tasks"
  type        = map(string)
  default     = {}
}

variable "ecs_service_desired_count" {
  description = "Desired count for ECS services"
  type        = map(number)
  default     = {}
}

variable "ecs_service_min_count" {
  description = "Minimum count for ECS services"
  type        = map(number)
  default     = {}
}

variable "ecs_service_max_count" {
  description = "Maximum count for ECS services"
  type        = map(number)
  default     = {}
}

variable "enable_autoscaling" {
  description = "Enable auto scaling"
  type        = bool
  default     = true
}

variable "autoscaling_target_cpu" {
  description = "Target CPU for autoscaling"
  type        = number
  default     = 70
}

variable "autoscaling_target_memory" {
  description = "Target memory for autoscaling"
  type        = number
  default     = 80
}
