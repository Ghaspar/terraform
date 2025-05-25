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
        "sts:TagSession",
        "sts:SetSourceIdentity"
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

    subnet_ids = aws_subnet.subnets[*].id

    scaling_config {
        desired_size = var.desired_size
        max_size     = var.max_size
        min_size     = var.min_size
    }
  
  depends_on = [ 
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
   ]
}