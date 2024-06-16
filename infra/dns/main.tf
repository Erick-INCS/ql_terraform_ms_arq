terraform {
  backend "s3" {
    bucket         = "epaa-terraform-state"
    key            = "dns.tfstate"
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
  region  = var.region
  profile = var.aws_profile
}

locals {
  env = terraform.workspace
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  workspace = terraform.workspace
  config = {
    bucket = var.tfstate_bucket
    key    = var.vpc_state_key
    region = var.region
  }
}

resource "aws_service_discovery_private_dns_namespace" "msif_dns_discovery" {
  name        = "msif-net-ns.${local.env}"
  description = "Microservice Infrastructre DNS Discovery"
  vpc         = data.terraform_remote_state.vpc.outputs.msif_vpc_id
  tags = {
    enviroment = local.env
    project = "msif"
  }
}