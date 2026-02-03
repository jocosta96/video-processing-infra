# Get EKS cluster information to access the cluster security group
data "aws_eks_cluster" "cluster" {
  name = "${var.service}-eks-cluster"
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

############################
# Locals
############################

locals {
  network_tags = {
    origin = "tc-micro-service-4/modules/eks/network.tf"
  }

  eks_managed_sg = data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

############################
# Secutiry Groups
############################

resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "${var.service}-eks-cluster-"
  vpc_id      = var.VPC_ID

  tags = merge(local.network_tags, {
    name = "${var.service}-eks-cluster-sg"
  })
}

resource "aws_security_group" "eks_node_sg" {
  name_prefix = "${var.service}-eks-node-"
  vpc_id      = var.VPC_ID

  tags = merge(local.network_tags, {
    name = "${var.service}-eks-node-sg"
  })
}

resource "aws_security_group" "nlb_sg" {
  name_prefix = "${var.service}-nlb-"
  vpc_id      = var.VPC_ID

  tags = merge(local.network_tags, { name = "${var.service}-nlb-sg" })
}

############################
# Internal Ingress Trafic (all open)
############################

############# NLB INGRESS ###############

# NODE > NLB
resource "aws_vpc_security_group_ingress_rule" "nlb_node_ingress" {
  security_group_id            = aws_security_group.nlb_sg.id
  referenced_security_group_id = aws_security_group.eks_node_sg.id
  ip_protocol                  = "-1"

  tags = merge(local.network_tags, { name = "${var.service}-node-to-nlb" })
}

# CLUSTER > NLB
resource "aws_vpc_security_group_ingress_rule" "nlb_cluster_ingress" {
  security_group_id            = aws_security_group.nlb_sg.id
  referenced_security_group_id = aws_security_group.eks_cluster_sg.id
  ip_protocol                  = "-1"

  tags = merge(local.network_tags, { name = "${var.service}-cluster-to-nlb" })
}

# BASTION > NLB
resource "aws_vpc_security_group_ingress_rule" "nlb_bastion_ingress" {
  security_group_id            = aws_security_group.nlb_sg.id
  referenced_security_group_id = var.bastion_security_group_id
  ip_protocol                  = "-1"

  tags = merge(local.network_tags, { name = "${var.service}-bastion-to-nlb" })
}

# CLUSTER INGRESS

# BASTION > CLUSTER
resource "aws_vpc_security_group_ingress_rule" "cluster_bastion_ingress" {
  security_group_id            = aws_security_group.eks_cluster_sg.id
  referenced_security_group_id = var.bastion_security_group_id
  ip_protocol                  = "-1"

  tags = merge(local.network_tags, { name = "${var.service}-bastion-to-cluster" })
}

# NODE > CLUSTER
resource "aws_vpc_security_group_ingress_rule" "eks_cluster_from_nodes" {
  security_group_id            = aws_security_group.eks_cluster_sg.id
  referenced_security_group_id = aws_security_group.eks_node_sg.id
  ip_protocol                  = "-1"

  tags = merge(local.network_tags, {
    name = "${var.service}-node-cluster"
  })
}

# NODE INGRESS

# BASTION > NODE
resource "aws_vpc_security_group_ingress_rule" "node_bastion_ingress" {
  security_group_id            = aws_security_group.eks_node_sg.id
  referenced_security_group_id = var.bastion_security_group_id
  ip_protocol                  = "-1"

  tags = merge(local.network_tags, { name = "${var.service}-bastion-to-cluster" })
}


# CLUSTER > NODE
resource "aws_vpc_security_group_ingress_rule" "eks_nodes_from_cluster" {
  security_group_id            = aws_security_group.eks_node_sg.id
  referenced_security_group_id = aws_security_group.eks_cluster_sg.id
  ip_protocol                  = "-1"

  tags = merge(local.network_tags, {
    name = "${var.service}-cluster-to-node"
  })
}


# NODE > NODE
resource "aws_vpc_security_group_ingress_rule" "eks_node_ingress_self" {
  security_group_id            = aws_security_group.eks_node_sg.id
  referenced_security_group_id = aws_security_group.eks_node_sg.id
  ip_protocol                  = "-1"

  tags = merge(local.network_tags, {
    name = "${var.service}-node-to-node"
  })
}

# NLB > NODE
resource "aws_vpc_security_group_ingress_rule" "nlb_to_node" {
  security_group_id            = aws_security_group.eks_node_sg.id
  referenced_security_group_id = aws_security_group.nlb_sg.id
  ip_protocol                  = "-1"

  tags = merge(local.network_tags, {
    name = "${var.service}-nlb-to-node"
  })
}

# NLB > EKS CLUSTER (EKS-managed security group)
resource "aws_vpc_security_group_ingress_rule" "nlb_to_eks_cluster" {
  security_group_id            = local.eks_managed_sg
  referenced_security_group_id = aws_security_group.nlb_sg.id
  ip_protocol                  = "-1"

  tags = merge(local.network_tags, {
    name = "${var.service}-nlb-to-eks-cluster"
  })
}

# BASTION > EKS CLUSTER (EKS-managed security group)
resource "aws_vpc_security_group_ingress_rule" "nlb_to_eks_cluster" {
  security_group_id            = local.eks_managed_sg
  referenced_security_group_id = var.bastion_security_group_id
  ip_protocol                  = "-1"

  tags = merge(local.network_tags, {
    name = "${var.service}-nlb-to-eks-cluster"
  })
}

############################
# EGRESS RULES
############################

resource "aws_vpc_security_group_egress_rule" "eks_cluster_egress" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(local.network_tags, { name = "${var.service}-cluster-egress" })
}

resource "aws_vpc_security_group_egress_rule" "eks_node_egress" {
  security_group_id = aws_security_group.eks_node_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(local.network_tags, { name = "${var.service}-node-egress" })
}

resource "aws_vpc_security_group_egress_rule" "nlb_egress" {
  security_group_id = aws_security_group.nlb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = merge(local.network_tags, { name = "${var.service}-nlb-egress" })
}