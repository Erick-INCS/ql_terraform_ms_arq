terraform {
  backend "s3" {
    bucket         = "epaa-terraform-state"
    key            = "ecs.tfstate"
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

resource "aws_ecs_cluster" "msif_ecs_cluster" {
  name = "msif_ecs_cluster_${local.env}"
  tags = {
    environment = local.env
    project = "msif"
  }
}