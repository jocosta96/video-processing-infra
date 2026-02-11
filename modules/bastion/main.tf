
locals {
  bastion_tags = {
    origin = "video-processing-infra/modules/bastion/main.tf"
  }

  allowed_ip_cidrs = ["0.0.0.0/0"]
}

# Security group for bastion host
resource "aws_security_group" "bastion_sg" {
  name_prefix = "${var.service}-bastion-"
  vpc_id      = var.vpc_id
  description = "Security group for ${var.service} bastion host"

  # Allow SSH from allowed IP CIDRs
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.allowed_ip_cidrs
    description = "SSH access from allowed IPs"
  }

  # Allow outbound to database
  egress {
    from_port   = var.database_port
    to_port     = var.database_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Access to database"
  }

  # Allow all outbound for general internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(local.bastion_tags, {
    Name = "${var.service}-bastion-sg"
  })
}

# EC2 instance for bastion host
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.bastion_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = var.subnet_ids[0] # Use first public subnet

  # Ephemeral environment settings
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "terminate"

  # IAM instance profile for SSM access
  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  # Enforce IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y postgresql15 unzip
    
    # Install latest kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    
    # Install aws-cli v2
    cd /tmp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    ./aws/install --update
    rm -rf aws awscliv2.zip

  EOF

  tags = merge(local.bastion_tags, {
    Name       = "${var.service}-bastion"
    Ephemeral  = "true"
    AutoDelete = "true"
  })
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name   = var.key_pair_name
  public_key = var.key_pair_value
}

resource "aws_ssm_parameter" "bastion_public_ip" {
  name  = "/${var.service}/bastion/public_ip"
  type  = "String"
  value = aws_instance.bastion.public_ip
}

resource "aws_ssm_parameter" "bastion_public_dns" {
  name  = "/${var.service}/bastion/public_dns"
  type  = "String"
  value = aws_instance.bastion.public_dns
}