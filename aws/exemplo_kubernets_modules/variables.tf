variable "prefix" {}

variable "vpc_cidr_block" {}


variable "cluster_name" {}
variable "retention_days" {
  default = 1
}

variable "desired_size" {}
variable "max_size" {}
variable "min_size" {}
