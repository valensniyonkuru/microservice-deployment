# Amazon MQ Configuration (RabbitMQ)
resource "aws_mq_broker" "main" {
  broker_name = "${var.project_name}-${var.environment}-rabbitmq"

  engine_type        = "RabbitMQ"
  engine_version     = "3.13"
  host_instance_type = var.instance_type
  deployment_mode    = var.deployment_mode

  user {
    username = var.rabbitmq_username
    password = var.rabbitmq_password
  }

  subnet_ids         = var.deployment_mode == "SINGLE_INSTANCE" ? [var.private_subnet_ids[0]] : var.private_subnet_ids
  security_groups    = [var.security_group_id]
  publicly_accessible = false

  # Logging
  logs {
    general = true
  }

  # Encryption
  encryption_options {
    use_aws_owned_key = true
  }

  # Maintenance
  maintenance_window_start_time {
    day_of_week = "SUNDAY"
    time_of_day = "03:00"
    time_zone   = "UTC"
  }

  # Auto minor version upgrade
  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.project_name}-${var.environment}-rabbitmq"
  }
}
