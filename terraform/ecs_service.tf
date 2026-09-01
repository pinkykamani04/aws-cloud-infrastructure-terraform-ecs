resource "aws_ecs_service" "app" {
  name            = "aws-cloud-infrastructure-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn

  desired_count = 2

  launch_type = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.private[0].id,
      aws_subnet.private[1].id
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 3000
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  tags = {
    Name        = "aws-cloud-infrastructure-ecs-service"
    Project     = "AWS Cloud Infrastructure Automation"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
