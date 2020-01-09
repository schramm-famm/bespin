variable "name" {
  type        = string
  description = "Name used to identify resources"
}

variable "security_group_id" {
  type        = string
  description = "ID of the security group to attach to EC2 container instances in the cluster"
}

variable "ec2_instance_profile_id" {
  type        = string
  description = "ID of the instance profile to attach to EC2 container instances in the cluster"
}

variable "subnets" {
  type        = list
  description = "List of subnets where EC2 container instances in the cluster will be deployed"
}
