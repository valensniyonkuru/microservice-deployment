output "alb_id" {
  description = "ALB ID"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB zone ID"
  value       = aws_lb.main.zone_id
}

output "target_group_books_arn" {
  description = "Books service target group ARN"
  value       = aws_lb_target_group.books.arn
}

output "target_group_customers_arn" {
  description = "Customers service target group ARN"
  value       = aws_lb_target_group.customers.arn
}

output "target_group_orders_arn" {
  description = "Orders service target group ARN"
  value       = aws_lb_target_group.orders.arn
}

output "http_listener_arn" {
  description = "HTTP listener ARN"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN (if configured)"
  value       = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : null
}
