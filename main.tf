variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of S3 bucket that stores config files"
  type        = string
  default     = "aws-tf-bucket-state"
}

variable "az" {
  type        = string
  description = "AWS availability zone"
  default     = "us-east-1a"
}

variable "node_root_disk_size" {
  type        = number
  description = "Disk size to allocate for nodes' root disk in GiB"
  default     = 512 # GB
}
variable "tenancy" {
  type        = string
  description = "Tenacy: default, dedicated or host"
  default     = "default"
}

variable "admin_public_key" {
  type = string
}

variable "base_instance_ami" {
  type        = string
  description = "AWS ami image to use for core instances"
  default     = "ami-02207126df36eb80c" # From https://cloud-images.ubuntu.com/locator/ec2/
}

variable "validator_node_instance_type" {
  type        = string
  description = "Instance type for validator nodes"
  default     = "m6g.large"
}

variable "validator_node_count" {
  type        = number
  description = "Count of validator nodes"
  default     = 1
}

module "aws-deployment" {
  source = "./tf-modules/aws"

  region                               = var.region
  bucket_name                          = var.bucket_name
  az                                   = var.az
  node_root_disk_size                  = var.node_root_disk_size
  tenancy                              = var.tenancy
  admin_public_key                     = var.admin_public_key
  base_instance_ami                    = var.base_instance_ami
  validator_node_instance_type          = var.validator_node_instance_type
  validator_node_count                  = var.validator_node_count
}

output "validator_node_ip_address" {
  value = module.aws-deployment.validator_node_ip_address
}
