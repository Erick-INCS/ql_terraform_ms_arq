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

variable "tfstate_bucket" {
  description = "terraform_state_bucket"
  type        = string
  default     =  "epaa-terraform-state"
}

variable "vpc_state_key" {
  description = "key_of_terraform_vpc_state"
  type        = string
  default     =  "vpc.tfstate"
}

