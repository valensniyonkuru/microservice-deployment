# Application Load Balancer
resource "aws_lb" "main" {
  name               = "lib-mgmt-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.environment == "prod" ? true : false
  enable_http2               = true
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}

# Target Groups
resource "aws_lb_target_group" "books" {
  name                 = "lib-mgmt-${var.environment}-books"
  port                 = 3000
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = {
    Name    = "${var.project_name}-${var.environment}-books-tg"
    Service = "books"
  }
}

resource "aws_lb_target_group" "customers" {
  name                 = "lib-mgmt-${var.environment}-cust"
  port                 = 3001
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = {
    Name    = "${var.project_name}-${var.environment}-customers-tg"
    Service = "customers"
  }
}

resource "aws_lb_target_group" "orders" {
  name                 = "lib-mgmt-${var.environment}-orders"
  port                 = 3002
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
  }

  tags = {
    Name    = "${var.project_name}-${var.environment}-orders-tg"
    Service = "orders"
  }
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service not found"
      status_code  = "404"
    }
  }
}

# HTTPS Listener (optional, requires certificate)
resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service not found"
      status_code  = "404"
    }
  }
}

# Listener Rules - Books Service
resource "aws_lb_listener_rule" "books_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.books.arn
  }

  condition {
    path_pattern {
      values = ["/books*", "/api/books*"]
    }
  }
}

resource "aws_lb_listener_rule" "books_https" {
  count        = var.certificate_arn != "" ? 1 : 0
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.books.arn
  }

  condition {
    path_pattern {
      values = ["/books*", "/api/books*"]
    }
  }
}

# Listener Rules - Customers Service
resource "aws_lb_listener_rule" "customers_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.customers.arn
  }

  condition {
    path_pattern {
      values = ["/customers*", "/api/customers*", "/auth*", "/api/auth*"]
    }
  }
}

resource "aws_lb_listener_rule" "customers_https" {
  count        = var.certificate_arn != "" ? 1 : 0
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.customers.arn
  }

  condition {
    path_pattern {
      values = ["/customers*", "/api/customers*", "/auth*", "/api/auth*"]
    }
  }
}

# Listener Rules - Orders Service
resource "aws_lb_listener_rule" "orders_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.orders.arn
  }

  condition {
    path_pattern {
      values = ["/orders*", "/api/orders*"]
    }
  }
}

resource "aws_lb_listener_rule" "orders_https" {
  count        = var.certificate_arn != "" ? 1 : 0
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.orders.arn
  }

  condition {
    path_pattern {
      values = ["/orders*", "/api/orders*"]
    }
  }
}
