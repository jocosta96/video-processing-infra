locals {
  network_tags = {
    origin = "tc-micro-service-4/modules/network/main.tf"
  }
}

resource "aws_vpc" "vpc" {
  tags                 = local.network_tags
  cidr_block           = var.VPC_CIDR_BLOCK
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "subnet" {
  tags                    = local.network_tags
  count                   = var.SUBNET_COUNT
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.VPC_CIDR_BLOCK, 4, count.index)
  map_public_ip_on_launch = false
  availability_zone       = var.AVAILABILITY_ZONES[count.index]
}

resource "aws_internet_gateway" "igw" {
  tags   = local.network_tags
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table" {
  tags   = local.network_tags
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "route_table_association" {
  count          = var.SUBNET_COUNT
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.route_table.id
}

# Private route table for database subnets (no Internet Gateway route)
resource "aws_route_table" "private_route_table" {
  tags   = local.network_tags
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = aws_vpc.vpc.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  # No route to Internet Gateway - database subnets are private
}
