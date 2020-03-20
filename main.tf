provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "ecs_base" {
  source             = "./modules/ecs_base"
  name               = var.name
  enable_nat_gateway = false
}

module "ecs_cluster" {
  source                  = "./modules/ecs_cluster"
  name                    = var.name
  security_group_ids      = [module.ecs_base.vpc_default_security_group_id]
  subnets                 = module.ecs_base.vpc_private_subnets
  ec2_instance_profile_id = module.ecs_base.ecs_instance_profile_id
}

module "docdb_cluster" {
  source             = "./modules/docdb_cluster"
  name               = var.name
  security_group_ids = [module.ecs_base.vpc_default_security_group_id]
  subnets            = module.ecs_base.vpc_private_subnets
  master_username    = var.docdb_username
  master_password    = var.docdb_password
}

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
