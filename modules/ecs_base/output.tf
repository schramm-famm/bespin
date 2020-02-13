output "vpc_default_security_group_id" {
  value = module.vpc.default_security_group_id
}

output "vpc_private_subnets" {
  value = module.vpc.private_subnets
}

output "vpc_public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecs_instance_profile_id" {
  value = aws_iam_instance_profile.ecs_agent.id
}
