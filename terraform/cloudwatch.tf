resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/aws-cloud-infrastructure-ecs"
  retention_in_days = 7

  tags = {
    Name        = "aws-cloud-infrastructure-ecs-logs"
    Project     = "AWS Cloud Infrastructure Automation"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
