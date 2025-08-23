
##################################################################################################################################
#RDS Primary
##################################################################################################################################


module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.10.0"
  count   = local.rds_instances.main.create ? 1 : 0

  identifier            = local.rds_instances.main.identifier
  engine                = local.rds_instances.main.engine
  engine_version        = local.rds_instances.main.engine_version
  family                = local.rds_instances.main.family               # DB parameter group
  major_engine_version  = local.rds_instances.main.major_engine_version # DB option group
  instance_class        = local.rds_instances.main.instance_class
  allocated_storage     = local.rds_instances.main.allocated_storage
  max_allocated_storage = local.rds_instances.main.max_allocated_storage
  storage_type          = local.rds_instances.main.storage_type
  db_name               = local.rds_instances.main.db_name
  username              = local.rds_instances.main.username
  #password =
  port                        = local.rds_instances.main.port
  manage_master_user_password = false
  multi_az                    = local.rds_instances.main.multi_az
  create_db_subnet_group      = true
  subnet_ids                  = module.vpc["main"].private_subnets
  vpc_security_group_ids      = [module.security_groups["rds"].security_group_id]
  maintenance_window          = local.rds_instances.main.maintenance_window
  backup_window               = local.rds_instances.main.backup_window
  backup_retention_period     = local.rds_instances.main.backup_retention_period
  skip_final_snapshot         = local.rds_instances.main.skip_final_snapshot
  deletion_protection         = local.rds_instances.main.deletion_protection
}

##################################################################################################################################
#RDS Replica
##################################################################################################################################

module "rds_replica" {
  source              = "terraform-aws-modules/rds/aws"
  version             = "6.10.0"
  count               = local.rds_instances.replica.create ? 1 : 0
  replicate_source_db = local.rds_instances.replica.replicate_source_db
  identifier          = local.rds_instances.replica.identifier
  instance_class      = local.rds_instances.replica.instance_class
  multi_az            = local.rds_instances.replica.multi_az
  skip_final_snapshot = local.rds_instances.replica.skip_final_snapshot
  deletion_protection = local.rds_instances.replica.deletion_protection
}
