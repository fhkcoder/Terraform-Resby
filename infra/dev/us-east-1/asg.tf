##################################################################################################################################
#Autoscaling Group Configuration
##################################################################################################################################

  module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "9.0.0"

  count = local.asg.create ? 1 : 0
  name = local.asg.name
    min_size                  = local.asg.min_size
    max_size                  = local.asg.max_size
    desired_capacity          = local.asg.desired_capacity
    wait_for_capacity_timeout = local.asg.wait_for_capacity_timeout     #keep it 0 for dev/test not for prod
   /*   health_check_type         = "ELB"
  health_check_grace_period = 300 # wait 5 min before starting health checks
  target_group_arns         = [aws_lb_target_group.example.arn]*/
    vpc_zone_identifier       = local.asg.vpc_zone_identifier

    instance_refresh = local.asg.instance_refresh
    # Launch template
    launch_template_name        = local.asg.launch_template_name
    launch_template_description = local.asg.launch_template_description
    update_default_version      = local.asg.update_default_version

    image_id          = data.aws_ami.ubuntu.image_id
    instance_type     = local.asg.instance_type
    ebs_optimized     = local.asg.ebs_optimized
    enable_monitoring = local.asg.enable_monitoring         # 5 minutes interval CW metrics for 5 mins free

    # IAM role & instance profile
    create_iam_instance_profile = local.asg.create_iam_instance_profile
    iam_role_name               = local.asg.iam_role_name
    iam_role_path               = local.asg.iam_role_path
    iam_role_description        = local.asg.iam_role_description
    iam_role_tags = local.asg.iam_role_tags
    iam_role_policies =local.asg.iam_role_policies

    block_device_mappings =local.asg.block_device_mappings
    cpu_options = local.asg.cpu_options
    credit_specification = local.asg.credit_specification

    instance_market_options = local.asg.instance_market_options

    # This will ensure imdsv2 is enabled, required, and a single hop which is aws security
    # best practices
    # See https://docs.aws.amazon.com/securityhub/latest/userguide/autoscaling-controls.html#autoscaling-4
    metadata_options = local.asg.metadata_options
    network_interfaces = local.asg.network_interfaces
    placement = local.asg.placement

    tag_specifications = local.asg.tag_specifications

    tags = local.asg.tags
  }
