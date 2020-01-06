variable "cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}

variable "create" {
  description = "Controls if ECS service should be created"
  type        = bool
  default     = true
}
