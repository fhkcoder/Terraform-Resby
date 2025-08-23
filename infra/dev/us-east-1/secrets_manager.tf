
##################################################################################################################################
#Secrets Manager Resources
##################################################################################################################################

resource "aws_secretsmanager_secret" "secrets" {
  for_each                = local.secrets_to_create
  name                    = each.value.name
  description             = each.value.description
  recovery_window_in_days = try(each.value.recovery_window_in_days, 7)
}

resource "aws_secretsmanager_secret_version" "rds_primary_credentials" {
  count         = contains(keys(local.secrets_to_create), "rds_primary_credentials") ? 1 : 0
  secret_id     = aws_secretsmanager_secret.secrets["rds_primary_credentials"].id
  secret_string = local.secrets["rds_primary_credentials"].secret_string

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret_version" "ec2_private_key" {
  count         = contains(keys(local.secrets_to_create), "ec2_private_key") ? 1 : 0
  secret_id     = aws_secretsmanager_secret.secrets["ec2_private_key"].id
  secret_string = tls_private_key.ec2_private_key[0].private_key_pem
}
