resource "aws_security_group" "sg-k8s" {
    name        = "${var.prefix}-sg"
    description = "Allow TLS inbound traffic and all outbound traffic"
    vpc_id      = var.vpc_id

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


# Attach AmazonEKSClusterPolicy à Role do cluster
resource "aws_iam_role_policy_attachment" "attach-cluster-policy" {
  role       = aws_iam_role.role-k8s.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Attach AmazonEKSVPCResourceController à Role do cluster
resource "aws_iam_role_policy_attachment" "attach-vpc-controller-policy" {
  role       = aws_iam_role.role-k8s.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}


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
    subnet_ids = var.subnet_ids
    security_group_ids = [
      aws_security_group.sg-k8s.id
    ]

  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_cloudwatch_log_group.log-k8s,
    aws_iam_role_policy_attachment.attach-role-policy-k8s,
    aws_iam_role_policy_attachment.attach-cluster-policy,
    aws_iam_role_policy_attachment.attach-vpc-controller-policy,
  ]
}




# nodes


# ------
# ----- IAM role and policy document assume ----------

data "aws_iam_policy_document" "ec2-node-k8s-policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = [
        "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role" "ec2-node-k8s-role" {
  name = "ec2-node-k8s-role"
  assume_role_policy = data.aws_iam_policy_document.ec2-node-k8s-policy.json
}


# Policys recomendadas para o ec2 node do kubernetes ---------

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  role        = aws_iam_role.ec2-node-k8s-role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  role        = aws_iam_role.ec2-node-k8s-role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  role        = aws_iam_role.ec2-node-k8s-role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "node-1" {
    cluster_name = aws_eks_cluster.cluster-teste-terraform.name
    node_group_name = "node-group-1"
    node_role_arn = aws_iam_role.ec2-node-k8s-role.arn

    instance_types = [ "t2.micro" ]

    subnet_ids = var.subnet_ids

    scaling_config {
        desired_size = var.desired_size
        max_size     = var.max_size
        min_size     = var.min_size
    }
  
  depends_on = [ 
    aws_eks_cluster.cluster-teste-terraform,
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
   ]
}