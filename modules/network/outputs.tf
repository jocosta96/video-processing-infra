output "service_vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "service_vpc_id" {
  value = aws_vpc.vpc.id
}

output "service_subnet_ids" {
  value = aws_subnet.subnet[*].id
}

output "service_private_subnet_ids" {
  value = aws_subnet.database_subnet[*].id
}

output "service_data_subnet_group_name" {
  value = aws_db_subnet_group.data_subnet_group.name
}

output "service_all_subnet_cdirs" {
  value = flatten(
    [
      aws_subnet.subnet[*].cidr_block,
      aws_subnet.database_subnet[*].cidr_block
    ]
  )
}