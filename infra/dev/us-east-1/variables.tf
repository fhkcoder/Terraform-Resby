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
  description = "Set to 1 to create redis, 0 to skip"
  type        = number
  default     = 0
}
