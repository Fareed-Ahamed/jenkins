variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "env" {
  description = "Deployment Environment (dev, stage, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}