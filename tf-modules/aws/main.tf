resource "aws_key_pair" "admin_key_pair" {
  key_name   = "admin_key_pair"
  public_key = var.admin_public_key
}

# resource "aws_dynamodb_table" "terraform-state" {
#  name           = "aws-tf-lock"
#  read_capacity  = 20
#  write_capacity = 20
#  hash_key       = "LockID"

#  attribute {
#    name = "LockID"
#    type = "S"
#  }
# }

# Security group restrictions
# TODO: restrict traffic for more secure setup
resource "aws_security_group" "collator_node_sg" {
  name        = "collator_node_sg"
  description = "Allow traffic ... for now."
  
  # Currently, we'll allow all communication
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "collator_node_sg"
  }
}

# TODO: review key storage options
# module "keystore" {
#   source = "./keystore"

#   key_spec = "ECC_SECG_P256K1"
#   alias    = "alias/eth_notice_signer-2"
# }

resource "aws_instance" "collator_node_public" {
  ami                         = var.base_instance_ami
  availability_zone           = var.az
  ebs_optimized               = true
  instance_type               = var.collator_node_instance_type
  key_name                    = aws_key_pair.admin_key_pair.key_name
  tenancy                     = var.tenancy
  vpc_security_group_ids      = [aws_security_group.collator_node_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = var.node_root_disk_size
    delete_on_termination = false
  }

  count = var.collator_node_count

  tags = {
    Name = "tangle_collator_node"
  }
}