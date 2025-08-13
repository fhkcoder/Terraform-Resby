variable "create_vpc" {
  description = "Set 1 to create vpcs, 0 to skip"
  type = number
  default = 0
}

variable "create_ec2_instance" {
  description = "Set 1 to create ec2_instance, 0 to skip"
  type = number
  default = 0
}

variable "create_key_pair" {
  description = "Set 1 to create key_pair, 0 to skip"
  type = number
  default = 0
}