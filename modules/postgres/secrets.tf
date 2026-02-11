locals {
  secret_tags = {
    origin = "video-processing-infra/modules/database/secrets.tf"
  }
}

# Database configuration parameters
resource "aws_ssm_parameter" "shared_database_host" {
  name        = "/${var.service}/database/host"
  description = "Database host endpoint for cross-repository integration"
  type        = "String"
  value       = aws_db_instance.database.address
  overwrite   = true

  tags = local.secret_tags
}

resource "aws_ssm_parameter" "shared_database_port" {
  name        = "/${var.service}/database/port"
  description = "Database port for cross-repository integration"
  type        = "String"
  value       = tostring(aws_db_instance.database.port)
  overwrite   = true

  tags = local.secret_tags
}

resource "aws_ssm_parameter" "shared_database_name" {
  name        = "/${var.service}/database/name"
  description = "Database name for cross-repository integration"
  type        = "String"
  value       = aws_db_instance.database.db_name
  overwrite   = true

  tags = local.secret_tags
}

resource "aws_ssm_parameter" "shared_database_username" {
  name        = "/${var.service}/database/username"
  description = "Database username for cross-repository integration"
  type        = "String"
  value       = aws_db_instance.database.username
  overwrite   = true

  tags = local.secret_tags
}

resource "aws_ssm_parameter" "shared_database_password" {
  name        = "/${var.service}/database/password"
  description = "Database password for cross-repository integration"
  type        = "SecureString"
  value       = random_password.db_password.result
  overwrite   = true

  tags = local.secret_tags
}
