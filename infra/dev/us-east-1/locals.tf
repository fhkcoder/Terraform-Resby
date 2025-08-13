locals {
    project = "resby"
    environment = "dev"
    name = "${project}-${environment}"
    instance_name = "${project}-${environment}-web"
    key = "${project}-${environment}-web-key"
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

  ec2_instances_to_create = {
    for k, v in local.ec2_instances : k => v if v.create
  }
  
  ec2_instances = {
    web = {
      create = var.create_ec2_instance > 0
      name = local.instance_name
      instance_type = "t2.micro"
      associate_public_ip_address = true
      subnet_type = "public"

      root_block_device = {
        volume_size = 8
        volume_type = "gp2"
        encrypted = true
      }
    }
  }

  key_pairs_to_create = {
    for k, v in local.key_pairs : k => v if v.create
  }

  key_pairs = {
    web-key = {
      create = var.create_key_pair > 0
      name = local.key
      algorithm = "RSA"
      rsa_bits = 4096
    }
  }
}
  