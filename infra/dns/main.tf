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
  region  = "us-east-1"
  profile = "terraform"
}



data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "epaa-terraform-state"
    key    = "backend.tfstate"
    region = "us-east-1"
  }
}


resource "aws_service_discovery_private_dns_namespace" "fgms_dns_discovery" {
  name        = var.fgms_private_dns_namespace
  description = "fgms dns discovery"
  vpc         = data.terraform_remote_state.vpc.outputs.fgms_vpc_id
}