locals {
  iam_tags = {
    origin = "video-processing-infra/modules/bastion/iam.tf"
  }
}

data "aws_iam_role" "bastion_role" {
  name = "LabRole"
}


# IAM instance profile
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.service}-bastion-profile"
  role = data.aws_iam_role.bastion_role.name

}

