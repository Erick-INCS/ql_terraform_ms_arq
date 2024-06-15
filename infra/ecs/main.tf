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


resource "aws_ecs_cluster" "fgms_ecs_cluster" {
  name = "fgms_ecs_cluster"
}