variable "name" {
  type        = string
  description = "Name used to identify resources"
}

variable "engine" {
  type        = string
  description = "Database engine type for the instance to run"
  default     = "mariadb"
}

variable "engine_version" {
  type        = string
  description = "Database engine version for the instance to run"
}

variable "port" {
  type        = number
  description = "Port for connecting to the database"
  default     = 3306
}

variable "master_username" {
  type        = string
  description = "Username for accessing the database"
}

variable "master_password" {
  type        = string
  description = "Password for accessing the database"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy the DB instance in"
}

variable "subnet_ids" {
  type        = list
  description = "List of subnets to deploy the DB instance in"
}