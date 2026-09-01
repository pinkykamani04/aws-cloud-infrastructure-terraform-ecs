resource "aws_ecs_cluster" "main" {
  name = "aws-cloud-infrastructure-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "aws-cloud-infrastructure-ecs-cluster"
    Project     = "AWS Cloud Infrastructure Automation"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
