locals {
  application = "resby"
  environment = "dev"
  name        = "${application}-${environment}"
  region      = "us-east-1"


  ##################################################################################################################################
  #VPC
  ##################################################################################################################################

  vpcs_to_create = {
    for k, v in local.vpcs : k => v if v.create
  }

  vpcs = {
    main = {
      create             = var.create_vpc > 0
      name               = local.name
      cidr               = "10.0.0.0/16"
      azs                = slice(data.aws_availability_zones.azs.names, 0, 2)
      enable_nat_gateway = false
      single_nat_gateway = false
      enable_vpn_gateway = false

      private_subnets = [for k, v in slice(data.aws_availability_zones.azs.names, 0, 2) : cidrsubnet("10.0.0.0/16", 4, k)]
      public_subnets  = [for k, v in slice(data.aws_availability_zones.azs.names, 0, 2) : cidrsubnet("10.0.0.0/16", 8, k + 48)]
      intra_subnets   = [for k, v in slice(data.aws_availability_zones.azs.names, 0, 2) : cidrsubnet("10.0.0.0/16", 8, k + 52)]

    }
  }


  ##################################################################################################################################
  #EC2
  ##################################################################################################################################

  ec2_instances_to_create = {
    for k, v in local.ec2_instances : k => v if v.create
  }

  ec2_instances = {
    web = {
      create                      = var.create_ec2_instance > 0
      name                        = "${local.name}-web"
      instance_type               = "t2.micro"
      associate_public_ip_address = true
      subnet_type                 = "public"

      root_block_device = {
        volume_size = 8
        volume_type = "gp2"
        encrypted   = true
      }
    }
  }

  ##################################################################################################################################
  #Key_Pairs
  ##################################################################################################################################


  key_pairs_to_create = {
    for k, v in local.key_pairs : k => v if v.create
  }

  key_pairs = {
    web-key = {
      create    = var.create_key_pair > 0
      name      = "${local.name}-web-key"
      algorithm = "RSA"
      rsa_bits  = 4096
    }
  }

  ##################################################################################################################################
  #Security Groups
  ##################################################################################################################################


  security_groups_to_create = {
    for k, v in local.security_groups : k => v if v.create
  }

  security_groups = {
    web_sg = {
      create      = var.create_ec2_security_group > 0
      name        = "${local.name}-web-sg"
      description = "Security group for web instances"
      vpc_id      = module.vpc.vpc_id

      ingress_cidr_blocks = [local.vpc.main.cidr]
      ingress_rules       = ["ssh-tcp"]
      ingress_with_cidr_blocks = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          description = "HTTP access"
          cidr_blocks = "0.0.0.0/0"
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          description = "HTTPS access"
          cidr_blocks = "0.0.0.0/0"
        },
        {
          from_port   = 6379
          to_port     = 6379
          protocol    = "tcp"
          description = "Redis access"
          cidr_blocks = local.vpc.main.cidr
        }
      ]
      egress_rules = ["all-all"]
    }

    redis = {
      create      = var.create_redis > 0
      name        = "${local.name}-redis"
      description = "Security group for redis-elasticache"
      ingress_with_cidr_blocks = [
        {
          from_port   = 6379
          to_port     = 6379
          protocol    = "tcp"
          description = "Cache store from ec2 instances"
          cidr_blocks = local.vpcs.main.cidr
        }
      ]
    }
  }


  ##################################################################################################################################
  #Redis Elasticache Configuration
  ##################################################################################################################################

  redis_to_create = {
    for k, v in local.redis : k => v if v.create
  }

  redis = {
    main = {
      create                   = var.create_redis > 0
      cluster_id               = "${local.name}-redis"
      create_cluster           = true
      create_replication_group = false

      engine_version = "7.1"
      node_type      = "cache.t4g.small"

      maintenance_window = "sun:05:00-sun:09:00"
      apply_immediately  = true
    }
  }

}
