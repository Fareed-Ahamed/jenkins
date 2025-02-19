variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}

variable "env" {
  description = "Deployment Environment (dev, stage, prod)"
  type        = string
}