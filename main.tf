provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

locals {
  vpc_cidr            = "10.1.0.0/16"
  vpc_azs             = ["us-east-2a", "us-east-2b"]
  vpc_private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  vpc_public_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]
}

/* BASE RESOURCES CONFIG */

module "ecs_base" {
  source             = "./modules/ecs_base"
  name               = var.name
  enable_nat_gateway = true
  cidr               = local.vpc_cidr
  azs                = local.vpc_azs
  private_subnets    = local.vpc_private_subnets
  public_subnets     = local.vpc_public_subnets
}

module "backend_ecs_cluster" {
  source                  = "./modules/ecs_cluster"
  name                    = "${var.name}-backend"
  security_group_ids      = [aws_security_group.service_instances.id]
  subnets                 = module.ecs_base.vpc_private_subnets
  ec2_instance_profile_id = module.ecs_base.ecs_instance_profile_id
  enable_efs              = true
  efs_id                  = aws_efs_file_system.ether.id
}

module "heimdall_ecs_cluster" {
  source                  = "github.com/schramm-famm/bespin//modules/ecs_cluster"
  name                    = "${var.name}-heimdall"
  security_group_ids      = [aws_security_group.service_instances.id]
  subnets                 = module.ecs_base.vpc_private_subnets
  ec2_instance_profile_id = module.ecs_base.ecs_instance_profile_id
}

module "frontend_ecs_cluster" {
  source                  = "github.com/schramm-famm/bespin//modules/ecs_cluster"
  name                    = "${var.name}-frontend"
  security_group_ids      = [aws_security_group.service_instances.id]
  subnets                 = module.ecs_base.vpc_private_subnets
  ec2_instance_profile_id = module.ecs_base.ecs_instance_profile_id
}

/* SECURITY GROUPS CONFIG */

resource "aws_security_group" "http_load_balancer" {
  name        = "${var.name}_http_load_balancer"
  description = "Allow HTTP traffic into load balancer"
  vpc_id      = module.ecs_base.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "https_load_balancer" {
  name        = "${var.name}_https_load_balancer"
  description = "Allow HTTPS traffic into load balancer"
  vpc_id      = module.ecs_base.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "service_instances" {
  name        = "${var.name}_service_instances"
  description = "Allow traffic for EC2 instances running microservices"
  vpc_id      = module.ecs_base.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "kafka" {
  name        = "${var.name}_kafka"
  description = "Allow traffic for Kafka instances"
  vpc_id      = module.ecs_base.vpc_id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "efs" {
  name        = "${var.name}_efs"
  description = "Allow NFS traffic into EFS mount targets"
  vpc_id      = module.ecs_base.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.service_instances.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* DATABASES CONFIG */

module "rds_instance" {
  source          = "./modules/rds_instance"
  name            = var.name
  engine          = "mariadb"
  engine_version  = "10.2.21"
  port            = 3306
  master_username = var.rds_username
  master_password = var.rds_password
  vpc_id          = module.ecs_base.vpc_id
  subnet_ids      = module.ecs_base.vpc_private_subnets
}

module "timescaledb_instance" {
  source                  = "./modules/timescaledb"
  name                    = var.name
  vpc_id                  = module.ecs_base.vpc_id
  subnets                 = module.ecs_base.vpc_private_subnets
  ecs_instance_profile_id = module.ecs_base.ecs_instance_profile_id
  internal                = true
  db_password             = var.timescaledb_password
}

/* KAFKA CONFIG */

data "aws_msk_configuration" "main" {
  name = "riht-kafka-main-2"
}

resource "aws_msk_cluster" "main" {
  cluster_name           = "main"
  kafka_version          = "2.3.1"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    ebs_volume_size = 1000
    client_subnets  = module.ecs_base.vpc_private_subnets
    security_groups = [aws_security_group.kafka.id]
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "PLAINTEXT"
    }
  }

  configuration_info {
    arn      = data.aws_msk_configuration.main.arn
    revision = data.aws_msk_configuration.main.latest_revision
  }
}

/* EFS CONFIG */

resource "aws_efs_file_system" "ether" {}

resource "aws_efs_mount_target" "ether" {
  count = length(local.vpc_private_subnets)

  file_system_id  = aws_efs_file_system.ether.id
  subnet_id       = module.ecs_base.vpc_private_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}

/* BACKEND SERVICES CONFIG */

module "heimdall" {
  source              = "github.com/schramm-famm/heimdall//terraform/modules/heimdall"
  name                = var.name
  container_tag       = var.heimdall_container_tag
  cluster_id          = module.heimdall_ecs_cluster.cluster_id
  vpc_id              = module.ecs_base.vpc_id
  external_lb_subnets = module.ecs_base.vpc_public_subnets
  internal_lb_subnets = module.ecs_base.vpc_private_subnets
  private_key_cert    = var.private_key_cert
  cert                = var.cert
  endpoints = {
    "karen"   = module.karen.elb_dns_name
    "ether"   = module.ether.elb_dns_name
    "patches" = module.patches.elb_dns_name
  }
}

module "karen" {
  source          = "github.com/schramm-famm/karen//terraform/modules/karen"
  name            = var.name
  container_tag   = var.karen_container_tag
  port            = 8081
  cluster_id      = module.backend_ecs_cluster.cluster_id
  security_groups = [aws_security_group.http_load_balancer.id]
  subnets         = module.ecs_base.vpc_private_subnets
  internal        = true
  db_location     = module.rds_instance.db_endpoint
  db_username     = var.rds_username
  db_password     = var.rds_password
}

module "ether" {
  source          = "github.com/schramm-famm/ether//terraform/modules/ether"
  name            = var.name
  container_tag   = var.ether_container_tag
  port            = 8082
  cluster_id      = module.backend_ecs_cluster.cluster_id
  security_groups = [aws_security_group.http_load_balancer.id]
  subnets         = module.ecs_base.vpc_private_subnets
  internal        = true
  db_location     = module.rds_instance.db_endpoint
  db_username     = var.rds_username
  db_password     = var.rds_password
  kafka_server    = split(",", aws_msk_cluster.main.bootstrap_brokers)[0]
  kafka_topic     = "updates"
  karen_endpoint  = module.karen.elb_dns_name
  efs_id          = aws_efs_file_system.ether.id
}

module "patches" {
  source            = "github.com/schramm-famm/patches?ref=sprint05//terraform/modules/patches"
  name              = var.name
  container_tag     = var.patches_container_tag
  port              = 8083
  cluster_id        = module.backend_ecs_cluster.cluster_id
  security_groups   = [aws_security_group.http_load_balancer.id]
  subnets           = module.ecs_base.vpc_private_subnets
  internal          = true
  db_host           = module.timescaledb_instance.db_host
  db_port           = module.timescaledb_instance.db_port
  db_username       = module.timescaledb_instance.db_username
  db_password       = var.timescaledb_password
  kafka_server      = split(",", aws_msk_cluster.main.bootstrap_brokers)[0]
  kafka_topic       = "updates"
  heimdall_endpoint = module.heimdall.internal_lb_dns_name
  ether_endpoint    = module.ether.elb_dns_name
}

/* FRONTEND SERVICE CONFIG */

module "me_you" {
  source          = "github.com/schramm-famm/me-you?ref=sprint05//terraform"
  name            = var.name
  container_tag   = var.me_you_container_tag
  cluster_id      = module.frontend_ecs_cluster.cluster_id
  security_groups = [aws_security_group.https_load_balancer.id]
  subnets         = module.ecs_base.vpc_public_subnets
  backend         = module.heimdall.external_lb_dns_name
  cert            = var.cert
  cert_key        = var.private_key_cert
}
