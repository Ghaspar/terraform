resource "aws_security_group" "sg-k8s" {
    name        = "${var.prefix}-sg"
    description = "Allow TLS inbound traffic and all outbound traffic"
    vpc_id      = aws_vpc.vpc-k8s.id

    tags = {
        Name = "${var.prefix}-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "sgi_k8s_ipv4" {
  security_group_id = aws_security_group.sg-k8s.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# resource "aws_vpc_security_group_ingress_rule" "sgi-k8s_ipv6" {
#   security_group_id = aws_security_group.sg-k8s.id
#   cidr_ipv6         = aws_vpc.main.ipv6_cidr_block
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

resource "aws_vpc_security_group_egress_rule" "sge_k8s_ipv4" {
  security_group_id = aws_security_group.sg-k8s.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# resource "aws_vpc_security_group_egress_rule" "sge_k8s_ipv6" {
#   security_group_id = aws_security_group.sg-k8s.id
#   cidr_ipv6         = "::/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }