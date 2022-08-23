# Backend
terraform {
  backend "s3" {
    bucket         = "aws-tf-bucket-state"
    key            = "terraform"
    region         = "us-east-1"
    dynamodb_table = "aws-tf-lock"
  }
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
