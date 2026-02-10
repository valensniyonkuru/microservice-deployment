output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.alb.alb_zone_id
}

output "ecr_repository_urls" {
  description = "ECR repository URLs for each service"
  value       = module.ecr.repository_urls
  sensitive   = false
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.database_name
}

output "rabbitmq_endpoint" {
  description = "RabbitMQ endpoint"
  value       = module.mq.endpoint
  sensitive   = true
}

output "rabbitmq_console_url" {
  description = "RabbitMQ management console URL"
  value       = module.mq.console_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = module.ecs_cluster.cluster_id
}

output "ecs_service_names" {
  description = "Names of ECS services"
  value       = module.ecs_services.service_names
}

output "books_service_url" {
  description = "Books service URL"
  value       = "http://${module.alb.alb_dns_name}/books"
}

output "customers_service_url" {
  description = "Customers service URL"
  value       = "http://${module.alb.alb_dns_name}/customers"
}

output "orders_service_url" {
  description = "Orders service URL"
  value       = "http://${module.alb.alb_dns_name}/orders"
}
