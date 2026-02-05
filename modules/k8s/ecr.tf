#mirror and cache Docker Hub images in ECR for faster pulls and reduced external dependencies

locals {
  ecr_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.region}.amazonaws.com"
  prefix  = "dockerhub/${var.service}"
  ecr_tags = merge({ repository = local.prefix })
}

resource "aws_ecr_repository" "service" {
  name                 = "dockerhub/${var.service}"
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  image_tag_mutability_exclusion_filter {
    filter      = "latest*"
    filter_type = "WILDCARD"
  }

  image_tag_mutability_exclusion_filter {
    filter      = "jharoldo*"
    filter_type = "WILDCARD"
  }

  image_tag_mutability_exclusion_filter {
    filter      = "jocosta96*"
    filter_type = "WILDCARD"
  }
}

resource "aws_ssm_parameter" "ecr_url" {
  name        = "${var.service}/ecr/url"
  description = "ecr repo url"
  type        = "String"
  value       = aws_ecr_repository.service.repository_url
  overwrite   = true

  tags = local.ecr_tags
}
