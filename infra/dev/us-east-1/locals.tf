
##################################################################################################################################
#Local Values
##################################################################################################################################

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
      vpc_id      = module.vpc["main"].vpc_id

      ingress_cidr_blocks = [local.vpcs.main.cidr]
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
          cidr_blocks = local.vpcs.main.cidr
        }
      ]
      egress_rules = ["all-all"]
    }

    rds = {
      create      = var.create_rds > 0
      name        = "${local.name}-rds"
      description = "Security group for rds postgres"
      vpc_id      = module.vpc["main"].vpc_id
      ingress_with_cidr_blocks = [
        {
          from_port   = 5432
          to_port     = 5432
          protocol    = "tcp"
          description = "RDS database for resby project"
          cidr_blocks = local.vpcs.main.cidr
        }
      ]
    }

    redis = {
      create      = var.create_redis > 0
      name        = "${local.name}-redis"
      description = "Security group for redis-elasticache"
      vpc_id      = module.vpc["main"].vpc_id
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
#RDS
##################################################################################################################################

  rds_to_create = {
    for k, v in local.rds_instances : k => v if v.create
  }

  rds_instances = {
    main = {
      create                = var.create_rds > 0
      identifier            = "${local.name}-postgres"
      engine                = "postgres"
      engine_version        = "15.7"
      family                = "postgres15" # DB parameter group
      major_engine_version  = "15.7"       # DB option group
      instance_class        = "db.t3.micro"
      allocated_storage     = 20
      max_allocated_storage = 100
      storage_type          = "gp3"
      db_name               = "resbydb"
      username              = "postgres"
      #password =
      port                                 = 5432
      multi_az                             = true
      maintenance_window                   = "Mon:00:00-Mon:03:00"
      backup_window                        = "03:00-06:00"
      backup_retention_period              = 7
      skip_final_snapshot                  = true
      deletion_protection                  = false

    }

    replica = {
      create = var.create_rds > 0 && var.create_rds_replica > 0 
      replicate_source_db = local.rds_instances["main"].identifier
      identifier            = "${local.name}-postgres-replica"
      instance_class        = "db.t3.micro"
      multi_az                             = false
      skip_final_snapshot                  = true
      deletion_protection                  = false
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
      node_type      = "cache.t3.micro"

      maintenance_window = "sun:05:00-sun:09:00"
      apply_immediately  = true
    }
  }


##################################################################################################################################
#Secrets Manager Configuration
##################################################################################################################################

secrets_to_create = {
  for k, v in local.secrets : k => v if v.create
}

secrets = {
  rds_primary_credentials = {
    create = var.create_rds > 0 || var.create_secrets > 0
    name = "${local.name}-rds_primary_credentials_v0"
    description = "RDS Postgres Primary DB Credentials"
    recovery_window_in_days = 0       #Immediate deletion
    secret_string = jsonencode ({
      username = local.rds_instances["main"].username
      password = "YOU_CAN_CHANGE_THIS_MANUALLY"       # This needs to be created prior to initializing RDS Primary
    })
    ignore_changes = true
  }

  ec2_private_key = {
    create = var.create_ec2_instance > 0
    name = "${local.name}-ec2_private_key_v0"
    description = "SSH Private Key for ec2 instance"
    ignore_changes = false
  }
}

tags = {
  Environment = local.environment
  Project = local.application
}
}