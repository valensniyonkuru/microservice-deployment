output "service_names" {
  description = "ECS service names"
  value       = { for k, v in aws_ecs_service.services : k => v.name }
}

output "service_ids" {
  description = "ECS service IDs"
  value       = { for k, v in aws_ecs_service.services : k => v.id }
}

output "task_definition_arns" {
  description = "ECS task definition ARNs"
  value       = { for k, v in aws_ecs_task_definition.services : k => v.arn }
}
