variable "name" {
  type        = string
  description = "Name used to identify resources"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs to associate with the DocumentDB cluster"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnets where the DocumentDB instances will be deployed"
}

variable "master_username" {
  type        = string
  description = "Username for the master DocumentDB user"
}

variable "master_password" {
  type        = string
  description = "Password for the master DocumentDB user"
}
