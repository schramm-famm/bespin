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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws" # 3rd party module
  version = "~> 2.0"

  name = var.name

  cidr = "10.1.0.0/16"

  # TODO: Don't hard code these three arguments
  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]

  enable_nat_gateway = var.enable_nat_gateway

  tags = {
    Name = var.name
  }
}
