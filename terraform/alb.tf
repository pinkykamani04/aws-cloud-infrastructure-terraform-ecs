resource "aws_lb" "app" {
  name               = "aws-cloud-infra-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]

  tags = {
    Name        = "aws-cloud-infrastructure-alb"
    Project     = "AWS Cloud Infrastructure Automation"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
resource "aws_lb_target_group" "app" {
  name        = "aws-cloud-infra-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name        = "aws-cloud-infrastructure-target-group"
    Project     = "AWS Cloud Infrastructure Automation"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
