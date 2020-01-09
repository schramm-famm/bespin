provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "ecs_base" {
  source = "./modules/ecs_base"
  name = var.name
}

/*
module "ecs_cluster" {
  name = var.name
}
*/

