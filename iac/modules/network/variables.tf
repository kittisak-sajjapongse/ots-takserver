variable "name" {
  type        = string
  description = "Name prefix for network resources."
  default     = "tak"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}
