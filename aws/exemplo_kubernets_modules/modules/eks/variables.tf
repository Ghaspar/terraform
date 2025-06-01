variable "prefix" {}
variable "cluster_name" {}
variable "vpc_id" {}

variable "subnet_ids" {
  
}

variable "retention_days" {
  default = 1
}

variable "desired_size" {}
variable "max_size" {}
variable "min_size" {}