variable "region" {
  description = "aws_region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "local_aws_profile"
  type        = string
  default     = "terraform"
}

# variable "fgms_api_service_namespace" {
#   description = "fgms api service namespace"
#   type        = string
#   default     = "fgms-api-service"
# }

variable "tfstate_bucket" {
  description = "terraform_state_bucket"
  type        = string
  default     = "epaa-terraform-state"
}

variable "vpc_state_key" {
  description = "key_of_terraform_vpc_state"
  type        = string
  default     = "vpc.tfstate"
}

# variable "dns_state_key" {
#   description = "key_of_terraform_dns_state"
#   type        = string
#   default     = "dns.tfstate"
# }

# variable "api_image" {
#   description = "api ecr image name"
#   type        = string
#   default     = "905418432534.dkr.ecr.us-east-1.amazonaws.com/fgms-dev"
# }

# variable "banxico_token" {
#   description = "BANXICO_TOKEN"
#   type        = string
#   sensitive   = true
# }

# variable "app_port" {
#   description = "API default port"
#   type        = number
#   default     = 80
# }