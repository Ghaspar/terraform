resource "aws_vpc" "vpc-k8s" {
    cidr_block = "10.0.0.0/16"
    tags={
        Name = "vpc-${var.prefix}"
    }
}

data "aws_availability_zones" "available" {
    state = "available"
}

# Caso queria pegar ali na hora as zonas disponiveis
# output "az" {
#     value = data.aws_availability_zones.available.names
# }

# subnet
resource "aws_subnet" "subnets" {
    count = 2
    availability_zone = element(data.aws_availability_zones.available.names, count.index)
    vpc_id = aws_vpc.vpc-k8s.id
    cidr_block = cidrsubnet(aws_vpc.vpc-k8s.cidr_block, 8, count.index)

    tags = {
        Name = "${var.prefix} subnet for ${element(data.aws_availability_zones.available.names, count.index)}"
    }
}

# Caso queira criar manualmente as subnets
# resource "aws_subnet" "subnet-k8s-1" {
#     availability_zone = "us-east-1a"
#     vpc_id = aws_vpc.vpc-k8s.id
#     cidr_block = "10.0.0.0/24"

#     tags = {
#         Name = "${var.prefix} subnet for us-east-1a"
#     }
# }

# resource "aws_subnet" "subnet-k8s-2" {
#     availability_zone = "us-east-1b"
#     vpc_id = aws_vpc.vpc-k8s.id
#     cidr_block = "10.0.1.0/24"

#     tags = {
#         Name = "${var.prefix} subnet for us-east-1b"
#     }
# }

#  Criando o gateway de internet / IGW
resource "aws_internet_gateway" "igw-k8s" {
  vpc_id = aws_vpc.vpc-k8s.id

  tags = {
    Name = "igw-${var.prefix}"
  }
}

# Criando o route table
resource "aws_route_table" "rt-k8s" {
  vpc_id = aws_vpc.vpc-k8s.id

  route {
    cidr_block = "0.0.0.0/0" # Deixando público para testar mais fácil
    gateway_id = aws_internet_gateway.igw-k8s.id
  }

  tags = {
    Name = "rt-${var.prefix}"
  }
}

resource "aws_route_table_association" "art-k8s" {
    count = 2
    subnet_id      = aws_subnet.subnets.*.id[count.index]
    route_table_id = aws_route_table.rt-k8s.id
}
