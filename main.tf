provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_ecs_cluster" "riht" {
  name = var.name
}

resource "aws_iam_role" "ecs_agent" {
  name = "${var.name}_ecs_instance_role"
  path = "/ecs/"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "${var.name}_ecs_instance_profile"
  role = aws_iam_role.ecs_agent.name
}

resource "aws_iam_role_policy_attachment" "ecs_agent_role" {
  role = aws_iam_role.ecs_agent.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_agent_cloudwatch_role" {
  role = aws_iam_role.ecs_agent.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
