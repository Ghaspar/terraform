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
  ip_protocol       = "-1" 
}

# resource "aws_vpc_security_group_egress_rule" "sge_k8s_ipv6" {
#   security_group_id = aws_security_group.sg-k8s.id
#   cidr_ipv6         = "::/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

# -----


# Roles do EKS
# Um pouco confuso, mas para uma role criada, você precisa criar um policy document e essa role deve assumir essa policy, depois vc faz o mesmo para a policy, criar uma policy, assume ela no policy document dela e depois no final vc vai atachar a role name com o policy document criado do policy.

# ------
# ----- IAM role and policy document assume ----------

data "aws_iam_policy_document" "assume_role_k8s" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = [
        "sts:AssumeRole",
        "sts:TagSession",
        "sts:SetSourceIdentity"
    ]
  }
}

resource "aws_iam_role" "role-k8s" {
  name = "role-${var.prefix}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_k8s.json
}

# ------
# ----- IAM policy and document policy assume ----------

data "aws_iam_policy_document" "policy-document-k8s" {
  statement {
    effect    = "Allow"
    actions   = [
        "sts:AssumeRole",
        "sts:TagSession",
        "sts:SetSourceIdentity"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy-iam-k8s" {
  name        = "policy-${var.prefix}"
  description = "A test policy"
  policy      = data.aws_iam_policy_document.policy-document-k8s.json
}

# ------
# ----- IAM role policy documento and policy document attachment ----------

resource "aws_iam_role_policy_attachment" "attach-role-policy-k8s" {
  role       = aws_iam_role.role-k8s.name
  policy_arn = aws_iam_policy.policy-iam-k8s.arn
}


# Aplicando cloudwatch nesse cluster

resource "aws_cloudwatch_log_group" "log-k8s" {
  name = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.retention_days
  tags = {
    Environment = "cluster_test"
    Application = "serviceA"
  }
}


# Subindo o clueter e atachando as roles criadas para ele


resource "aws_eks_cluster" "cluster-teste-terraform" {
  name = "${var.cluster_name}"

  # access_config {
  #   authentication_mode = "API"
  # }

  role_arn = aws_iam_role.role-k8s.arn
  version  = "1.31"

  enabled_cluster_log_types = [ "api", "audit" ]


  vpc_config {
    subnet_ids = aws_subnet.subnets[*].id
    security_group_ids = [
      aws_security_group.sg-k8s.id
    ]

  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_cloudwatch_log_group.log-k8s,
    aws_iam_role_policy_attachment.attach-role-policy-k8s
  ]
}

