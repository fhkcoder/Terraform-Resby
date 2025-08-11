module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"
  
  for_each = local.vpcs_to_create

  name = each.value.name
  cidr = each.value.cidr

  azs             = each.value.azs
  private_subnets = each.value.private_subnets
  public_subnets  = each.value.public_subnets

  enable_nat_gateway = each.value.enable_nat_gateway
  enable_vpn_gateway = each.value.enable_vpn_gateway
  single_nat_gateway = each.value.single_nat_gateway

  }