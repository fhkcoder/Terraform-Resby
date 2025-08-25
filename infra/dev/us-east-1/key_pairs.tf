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
