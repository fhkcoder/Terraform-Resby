
##################################################################################################################################
#Resources to Create
##################################################################################################################################

variable "create_vpc" {
  description = "Set 1 to create vpcs, 0 to skip"
  type        = number
  default     = 0
}

variable "create_ec2_instance" {
  description = "Set 1 to create ec2 instance, 0 to skip"
  type        = number
  default     = 0
}

variable "create_key_pair" {
  description = "Set 1 to create key pair, 0 to skip"
  type        = number
  default     = 0
}

variable "create_ec2_security_group" {
  description = "Set 1 to create ec2 security group, 0 to skip"
  type        = number
  default     = 0
}

variable "create_redis" {
  description = "Set 1 to create redis, 0 to skip"
  type        = number
  default     = 0
}

variable "create_rds" {
  description = "Set 1 to create rds, 0 to skip"
  type        = number
  default     = 0
}

variable "create_rds_replica" {
  description = "Set 1 to create rds replica, 0 to skip"
  type        = number
  default     = 0
}

variable "create_secrets" {
  description = "Set 1 to create secrets for secret manager, 0 to skip"
  type = number
  default = 0
}

variable "create_asg" {
  description = "Set 1 to create auto-scaling group, 0 to skip"
  type = number
  default = 0
}

variable "create_elb" {
  description = "Set 1 to create elb, 0 to skip"
  type = number
  default = 0
}