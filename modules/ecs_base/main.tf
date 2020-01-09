resource "aws_ecs_cluster" "this" {
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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws" # 3rd party module
  version = "~> 2.0"

  name = var.name

  cidr = "10.1.0.0/16"

  # TODO: Don't hard code these three arguments
  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]

  enable_nat_gateway = true

  tags = {
    Name = var.name
  }
}

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws" # 3rd party module
  version = "~> 3.0"

  name = var.name

  # Launch configuration
  lc_name = "${var.name}_launch_configuration"

  image_id             = data.aws_ami.amazon_linux_ecs.id
  instance_type        = "t2.micro"
  security_groups      = [module.vpc.default_security_group_id]
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.id
  user_data            = data.template_file.user_data.rendered

  # Auto scaling group
  asg_name                  = "${var.name}_asg"
  vpc_zone_identifier       = module.vpc.private_subnets
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Cluster"
      value               = var.name
      propagate_at_launch = true
    },
  ]
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    cluster_name = var.name
  }
}
