resource "aws_cloudwatch_log_group" "example" {
  count = var.create ? 1 : 0
  name              = "example"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "example" {
  count = var.create ? 1 : 0
  family = "example"

  container_definitions = <<EOF
[
  {
    "name": "example",
    "image": "343660461351.dkr.ecr.us-east-2.amazonaws.com/riht:latest",
    "cpu": 10,
    "memory": 128,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080,
        "protocol": "tcp"
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "example" {
  count = var.create ? 1 : 0
  name = "example"
  cluster = var.cluster_id
  task_definition = aws_ecs_task_definition.example.arn

  desired_count = 1
}
