variable "name" {
  type        = string
  description = "Name used to identify resources"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Toggle the creation of a NAT gateway in the VPC"
  default     = false
}

variable "cidr" {
  type        = string
  description = "CIDR range for the VPC"
  default     = "10.1.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones for the VPC"
  default     = ["us-east-2a", "us-east-2b"]
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets for the VPC"
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets for the VPC"
  default     = ["10.1.11.0/24", "10.1.12.0/24"]
}
