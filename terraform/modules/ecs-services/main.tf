locals {
  # Service configurations
  service_configs = {
    books = {
      port           = 3000
      cpu            = lookup(var.ecs_task_cpu, "books", "256")
      memory         = lookup(var.ecs_task_memory, "books", "512")
      desired_count  = lookup(var.ecs_service_desired_count, "books", 2)
      min_count      = lookup(var.ecs_service_min_count, "books", 1)
      max_count      = lookup(var.ecs_service_max_count, "books", 4)
      target_group   = var.alb_target_group_books_arn
      env_vars       = {}
    }
    customers = {
      port           = 3001
      cpu            = lookup(var.ecs_task_cpu, "customers", "256")
      memory         = lookup(var.ecs_task_memory, "customers", "512")
      desired_count  = lookup(var.ecs_service_desired_count, "customers", 2)
      min_count      = lookup(var.ecs_service_min_count, "customers", 1)
      max_count      = lookup(var.ecs_service_max_count, "customers", 4)
      target_group   = var.alb_target_group_customers_arn
      env_vars       = {
        JWT_SECRET = var.jwt_secret
      }
    }
    orders = {
      port           = 3002
      cpu            = lookup(var.ecs_task_cpu, "orders", "256")
      memory         = lookup(var.ecs_task_memory, "orders", "512")
      desired_count  = lookup(var.ecs_service_desired_count, "orders", 2)
      min_count      = lookup(var.ecs_service_min_count, "orders", 1)
      max_count      = lookup(var.ecs_service_max_count, "orders", 4)
      target_group   = var.alb_target_group_orders_arn
      env_vars       = {}
    }
  }
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "services" {
  for_each = toset(var.services)

  family                   = "${var.project_name}-${var.environment}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.service_configs[each.key].cpu
  memory                   = local.service_configs[each.key].memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = "${var.ecr_repository_urls[each.key]}:latest"
      essential = true

      portMappings = [
        {
          containerPort = local.service_configs[each.key].port
          protocol      = "tcp"
        }
      ]

      environment = concat(
        [
          {
            name  = "NODE_ENV"
            value = "production"
          },
          {
            name  = "PORT"
            value = tostring(local.service_configs[each.key].port)
          },
          {
            name  = "DB_HOST"
            value = split(":", var.database_endpoint)[0]
          },
          {
            name  = "DB_PORT"
            value = "5432"
          },
          {
            name  = "DB_USERNAME"
            value = var.database_username
          },
          {
            name  = "DB_PASSWORD"
            value = var.database_password
          },
          {
            name  = "DB_DATABASE"
            value = var.database_name
          },
          {
            name  = "RABBITMQ_URL"
            value = var.rabbitmq_endpoint
          }
        ],
        [
          for k, v in local.service_configs[each.key].env_vars : {
            name  = k
            value = v
          }
        ]
      )

      healthCheck = {
        command     = ["CMD-SHELL", "node -e \"require('http').get('http://localhost:${local.service_configs[each.key].port}/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})\""]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name    = "${var.project_name}-${var.environment}-${each.key}-task"
    Service = each.key
  }
}

# ECS Services
resource "aws_ecs_service" "services" {
  for_each = toset(var.services)

  name            = "${var.project_name}-${var.environment}-${each.key}"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.services[each.key].arn
  desired_count   = local.service_configs[each.key].desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = local.service_configs[each.key].target_group
    container_name   = each.key
    container_port   = local.service_configs[each.key].port
  }

  health_check_grace_period_seconds = 60

  tags = {
    Name    = "${var.project_name}-${var.environment}-${each.key}-service"
    Service = each.key
  }

  depends_on = [
    aws_ecs_task_definition.services
  ]

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Auto Scaling Target
resource "aws_appautoscaling_target" "services" {
  for_each = var.enable_autoscaling ? toset(var.services) : []

  max_capacity       = local.service_configs[each.key].max_count
  min_capacity       = local.service_configs[each.key].min_count
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.services[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy - CPU
resource "aws_appautoscaling_policy" "cpu" {
  for_each = var.enable_autoscaling ? toset(var.services) : []

  name               = "${var.project_name}-${var.environment}-${each.key}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.services[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.services[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.services[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.autoscaling_target_cpu
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Auto Scaling Policy - Memory
resource "aws_appautoscaling_policy" "memory" {
  for_each = var.enable_autoscaling ? toset(var.services) : []

  name               = "${var.project_name}-${var.environment}-${each.key}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.services[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.services[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.services[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.autoscaling_target_memory
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Data source for current region
data "aws_region" "current" {}
