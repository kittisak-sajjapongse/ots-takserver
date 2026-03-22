variable "vpc_id" {
  type        = string
  description = "VPC ID for the security group."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to place the instance in."
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

variable "user_data_template" {
  type        = string
  description = "Path to the user data template file."
}
