terraform {
  backend "s3" {
    bucket         = "epaa-terraform-state"
    key            = "service-api.tfstate"
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

data "terraform_remote_state" "dns" {
  backend = "s3"
  workspace = terraform.workspace
  config = {
    bucket = var.tfstate_bucket
    key    = var.dns_state_key
    region = var.region
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"
  workspace = terraform.workspace
  config = {
    bucket = var.tfstate_bucket
    key    = "alb.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"
  workspace = terraform.workspace
  config = {
    bucket = var.tfstate_bucket
    key    = "ecs.tfstate"
    region = var.region
  }
}

resource "aws_iam_policy" "msif_api_task_role_policy" {
  name        = "msif_api_task_role_policy"
  description = "msif api task role policy"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect : "Allow",
          Action : [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Resource : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role" "msif_api_task_role" {
  name = "msif_api_${local.env}_task_role"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect : "Allow",
          Principal : {
            Service : "ecs-tasks.amazonaws.com"
          },
          Action : [
            "sts:AssumeRole"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.msif_api_task_role.name
  policy_arn = aws_iam_policy.msif_api_task_role_policy.arn
}

resource "aws_cloudwatch_log_group" "msif_log_group" {
  name = "/ecs/msif_${local.env}_log_group"

}

resource "aws_ecs_task_definition" "msif_api_td" {
  family                   = "msif_api_${local.env}_td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.msif_api_task_role.arn

  container_definitions = jsonencode(
    [
      {
        cpu : 256,
        image : var.api_image,
        memory : 512,
        name : "msif-api",
        networkMode : "awsvpc",
        environment : [
          {
            name : "BANXICO_TOKEN",
            value : var.banxico_token
          },
        ],
        portMappings : [
          {
            containerPort : var.app_port,
            hostPort : var.app_port
          }
        ],
        logConfiguration : {
          logDriver : "awslogs",
          options : {
            awslogs-group : "/ecs/msif_${local.env}_log_group",
            awslogs-region : var.region,
            awslogs-stream-prefix : "api"
          }
        }
      }
    ]
  )
}

resource "aws_ecs_service" "msif_api_td_service" {
  name            = "msif_api_${local.env}_td_service"
  cluster         = data.terraform_remote_state.ecs_cluster.outputs.msif_ecs_cluster_id
  task_definition = aws_ecs_task_definition.msif_api_td.arn
  desired_count   = "1"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    subnets         = [data.terraform_remote_state.vpc.outputs.msif_private_subnets_ids[0]]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.msif_api_tg.id
    container_name   = "msif-api"
    container_port   = var.app_port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.msif_api_service.arn
  }
}

resource "aws_security_group" "ecs_tasks_sg" {
  name        = "ecs_tasks_sg_${local.env}"
  description = "allow inbound access from the ALB only"
  vpc_id      = data.terraform_remote_state.vpc.outputs.msif_vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [data.terraform_remote_state.alb.outputs.msif_alb_sg_id]
  }

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    self      = true
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_alb_target_group" "msif_api_tg" {
  name        = "msif-api-tg-${local.env}"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.msif_vpc_id
  target_type = "ip"
  health_check {
    path = "/healthcheck"
  }
}

resource "aws_alb_listener" "msif_api_tg_listener" {
  load_balancer_arn = data.terraform_remote_state.alb.outputs.msif_alb_id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.msif_api_tg.id
    type             = "forward"
  }
}


resource "aws_service_discovery_service" "msif_api_service" {
  name = var.msif_api_service_namespace

  dns_config {
    namespace_id = data.terraform_remote_state.dns.outputs.msif_dns_discovery_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 2
  }
}