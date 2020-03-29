resource "aws_ecs_cluster" "this" {
  name = var.name
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
  security_groups      = var.security_group_ids
  iam_instance_profile = var.ec2_instance_profile_id

  user_data = <<EOF
${templatefile("${path.module}/user_data.sh", { cluster_name = var.name })}
%{if var.enable_efs}
${templatefile("${path.module}/efs_setup.sh", { efs_id = var.efs_id })}
%{endif}
echo "Done"
EOF

  # Auto scaling group
  asg_name                  = "${var.name}_asg"
  vpc_zone_identifier       = var.subnets
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
