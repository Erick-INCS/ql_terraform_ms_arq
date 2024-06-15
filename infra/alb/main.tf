terraform {
  backend "s3" {
    bucket         = "epaa-terraform-state"
    key            = "alb.tfstate"
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


data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.tfstate_bucket
    key    = var.vpc_state_key
    region = var.region
  }
}


resource "aws_lb" "fgms_alb" {
  load_balancer_type = "application"
  subnets            = data.terraform_remote_state.vpc.outputs.fgms_public_subnets_ids
  security_groups    = ["${aws_security_group.fgms_alb_sg.id}"]
}

resource "aws_security_group" "fgms_alb_sg" {
  description = "controls access to the ALB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.fgms_vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}