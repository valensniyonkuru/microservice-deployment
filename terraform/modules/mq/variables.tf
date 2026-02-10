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

variable "security_group_id" {
  description = "Security group ID for Amazon MQ"
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

variable "instance_type" {
  description = "Amazon MQ instance type"
  type        = string
}

variable "deployment_mode" {
  description = "Deployment mode (SINGLE_INSTANCE or CLUSTER_MULTI_AZ)"
  type        = string
  default     = "SINGLE_INSTANCE"
}
