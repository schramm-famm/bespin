variable "name" {
  type        = string
  description = "Name used to identify resources"
}

variable "security_group_ids" {
  type        = list(string)
  description = "IDs of the security groups to attach to EC2 container instances in the cluster"
}

variable "ec2_instance_profile_id" {
  type        = string
  description = "ID of the instance profile to attach to EC2 container instances in the cluster"
}

variable "subnets" {
  type        = list
  description = "List of subnets where EC2 container instances in the cluster will be deployed"
}

variable "enable_efs" {
  type        = bool
  description = "Toggle the mounting of an EFS file system on the EC2 container instances"
  default     = false
}

variable "efs_id" {
  type        = string
  description = "ID of the EFS file system to mount on the EC2 container instances"
  default     = ""
}
