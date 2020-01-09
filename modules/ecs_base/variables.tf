variable "name" {
  type        = string
  description = "Name used to identify resources"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Toggle the creation of a NAT gateway in the VPC"
  default     = false
}
