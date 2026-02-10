output "id" {
  description = "Amazon MQ broker ID"
  value       = aws_mq_broker.main.id
}

output "arn" {
  description = "Amazon MQ broker ARN"
  value       = aws_mq_broker.main.arn
}

output "endpoint" {
  description = "Amazon MQ AMQP endpoint"
  value       = aws_mq_broker.main.instances[0].endpoints[0]
}

output "console_url" {
  description = "Amazon MQ web console URL"
  value       = aws_mq_broker.main.instances[0].console_url
}
