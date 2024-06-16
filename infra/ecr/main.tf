terraform {
  backend "s3" {
    bucket         = "epaa-terraform-state"
    key            = "ecr.tfstate"
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

# locals {
#   env = terraform.workspace
# }

# Same repo for all enviroments (we can deploy a different tag)
resource "aws_ecr_repository" "msif-api-ecr-repo" {
  name = "msif-api"
}