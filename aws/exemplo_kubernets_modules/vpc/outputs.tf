output "vpc_id" {
  value = aws_vpc.vpc-k8s.id
}

output "subnet_ids" {
  value = aws_subnet.subnets[*].id
  
}