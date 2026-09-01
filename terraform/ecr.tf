resource "aws_ecr_repository" "app" {
  name                 = "aws-cloud-infrastructure-ecs"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = {
    Name        = "aws-cloud-infrastructure-ecs-ecr"
    Project     = "AWS Cloud Infrastructure Automation"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
