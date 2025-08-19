module "elasticache" {
  count   = local.redis.main.create ? 1 : 0
  source  = "terraform-aws-modules/elasticache/aws"
  version = "1.6.2"

  cluster_id               = local.redis.main.cluster_id
  create_cluster           = local.redis.main.create_cluster
  create_replication_group = local.redis.main.create_replication_group

  engine_version = local.redis.main.engine_version
  node_type      = local.redis.main.node_type

  maintenance_window = local.redis.main.maintenance_window
  apply_immediately  = local.redis.main.apply_immediately

  # Security group
  vpc_id             = module.vpc["main"].vpc_id
  security_group_ids = [module.security_groups["redis"].security_group_id]

  # Subnet Group
  subnet_ids = module.vpc["main"].private_subnets

  /*# Parameter Group
  create_parameter_group = true
  parameter_group_family = "redis7"
  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }*/
}
