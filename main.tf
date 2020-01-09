provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "ecs_base" {
  source = "./modules/ecs_base"
  name = var.name
}

module "ecs_cluster" {
  source = "./modules/ecs_cluster"
  name = var.name
  vpc_default_security_group_id = module.ecs_base.vpc_default_security_group_id
  subnets = module.ecs_base.vpc_private_subnets
  ecs_instance_profile_id = module.ecs_base.ecs_instance_profile_id
}
