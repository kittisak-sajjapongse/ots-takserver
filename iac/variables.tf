variable "aws_region" {
  type        = string
  description = "AWS region to deploy into."
}

variable "instance_size" {
  type        = string
  description = "EC2 instance size."
}

variable "ssd_size_gb" {
  type        = number
  description = "Root volume size in GB."
}

variable "admin_user" {
  type        = string
  description = "Admin SSH username to configure on the instance."
}

variable "admin_password" {
  type        = string
  description = "Admin SSH password to configure on the instance."
  sensitive   = true
}
