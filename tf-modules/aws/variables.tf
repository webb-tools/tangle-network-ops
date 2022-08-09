
variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of S3 bucket that stores state files"
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

variable "collator_node_instance_type" {
  type        = string
  description = "Instance type for collating nodes"
  default     = "m6g.large"
}

variable "collator_node_count" {
  type        = number
  description = "Count of collator nodes"
  default     = 1
}