output "name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "node_group_name" {
  value = aws_eks_node_group.eks_node_group.node_group_name
}

output "eks_security_group_id" {
  value = aws_security_group.eks_cluster_sg.id
}

output "eks_node_security_group_id" {
  description = "Security group ID for EKS worker nodes (where pods run)"
  value       = aws_security_group.eks_node_sg.id
}

output "eks_load_balancer_name" {
  value = aws_lb.app_nlb.name
}

output "eks_load_balancer_arn" {
  value = aws_lb.app_nlb.arn
}

output "eks_load_balancer_dns_name" {
  value = aws_lb.app_nlb.dns_name
}

output "nlb_target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}