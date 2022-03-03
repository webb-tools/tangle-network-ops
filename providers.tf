# Backend
terraform {
  backend "s3" {}
}
#TODO: add additional cloud providers
# Configuration for AWS
provider "aws" {
  region = var.region
}

# AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
