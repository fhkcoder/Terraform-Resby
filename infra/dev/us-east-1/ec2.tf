########################################################################
#EC2 module
########################################################################

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.0.2"

  for_each = local.ec2_instances_to_create

  name = each.value.name

  instance_type = each.value.instance_type
  ami           = data.aws_ami.ubuntu.id
  subnet_id     = each.value.subnet_type == "public" ? (module.vpc["main"].public_subnets[0]) : (module.vpc["main"].private_subnets[0])
  key_name      = local.key_pairs["web-key"].create ? aws_key_pair.ec2_key[0].key_name : null

  associate_public_ip_address = each.value.associate_public_ip_address
  root_block_device           = each.value.root_block_device


}

########################################################################
#EC2 supporting resources
########################################################################

resource "tls_private_key" "ec2_private_key" {
  count     = local.key_pairs["web-key"].create ? 1 : 0
  algorithm = local.key_pairs["web-key"].algorithm
  rsa_bits  = local.key_pairs["web-key"].rsa_bits
}

resource "aws_key_pair" "ec2_key" {
  count      = local.key_pairs["web-key"].create ? 1 : 0
  key_name   = local.key_pairs["web-key"].name
  public_key = tls_private_key.ec2_private_key[0].public_key_openssh
}
