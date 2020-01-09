variable "name" {
  type = string
}

variable "vpc_default_security_group_id" {
  type = string
}

variable "ecs_instance_profile_id" {
  type = string
}

variable "subnets" {
  type = list
}
