module "security_groups" {
  source = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"
  for_each = local.security_groups_to_create

  name        = each.value.name
  description = each.value.description
  vpc_id      = each.value.vpc_id

  ingress_cidr_blocks      = each.value.ingress_cidr_blocks
  ingress_rules            = each.value.ingress_rules
  ingress_with_cidr_blocks = each.value.ingress_with_cidr_blocks
}