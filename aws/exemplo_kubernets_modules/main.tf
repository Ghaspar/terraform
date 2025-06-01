module "new-vpc" {
    source = "./modules/vpc"

    prefix = var.prefix
    vpc_cidr_block = var.vpc_cidr_block
  
}

module "eks" {
    source = "./modules/eks"

    prefix = var.prefix

    cluster_name = var.cluster_name
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
    retention_days = var.retention_days
    subnet_ids = module.new-vpc.subnet_ids
    

    vpc_id = module.new-vpc.vpc_id
}