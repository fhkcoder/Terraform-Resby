locals {
    environment = "dev"
    name = "Resby-${environment}"
    region = "us-east-1"

  vpcs_to_create = {
    for k, v in local.vpcs : k => v if v.create
  }

  vpcs = {
    main = {
        create = var.create_vpc > 0
        name = local.name
        cidr = "10.0.0.0/16"
        azs = slice(data.aws_availability_zones.azs.names,0,2)
        enable_nat_gateway = false
        single_nat_gateway = false
        enable_vpn_gateway = false

        private_subnets = [for k, v in slice(data.aws_availability_zones.azs.names,0,2) : cidrsubnet("10.0.0.0/16", 4, k)]
        public_subnets = [for k, v in slice(data.aws_availability_zones.azs.names,0,2) : cidrsubnet("10.0.0.0/16", 8, k + 48)]
        intra_subnets = [for k, v in slice(data.aws_availability_zones.azs.names,0,2) : cidrsubnet("10.0.0.0/16", 8, k + 52)]

    }
  }
}