terraform {
  backend "s3" {
    bucket         = "epaa-terraform-state"
    key            = "backend.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-backend"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
  }
}


provider "aws" {
  region  = "us-east-1"
  profile = "terraform"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "fgms-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    group       = "fgms"
    Environment = "dev"
  }
}