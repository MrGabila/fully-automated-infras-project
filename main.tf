################################## PROVIDERS #######################################################
provider "aws" {
  region = "us-east-1"
}

################################## VARIABLES #######################################################
variable "key_pair_name" {
  type        = string
  description = "the SSH Keypair"
  default = "dzeko-Virginia-region"
}

locals {
  common_tags = {
    company    = "Bluejay.internal"
    owner      = "Gabinator"
    team-email = "devops-team@bluejay.com"
    time       = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
  }

}

################################## MODULES #########################################################
# module to create IAM role and policy for the CloudWatch access
module "iam" {
  source = "./iam"
  name   = local.common_tags.company
  tags   = local.common_tags
}

# module code to create the ec2 instance with user data
module "ec2_dev" {
  source        = "./ec2"
  name          = "automated-dev"
  tags          = local.common_tags
  iam_role_name = module.iam.ec2_iam_role_name
  key_pair_name = var.key_pair_name
}

# module code to create the ec2 instance with user data.
module "ec2_stage" {
  source        = "./ec2"
  name          = "automated-stage"
  tags          = local.common_tags
  iam_role_name = module.iam.ec2_iam_role_name
  key_pair_name = var.key_pair_name
}

# module code to create the ec2 instance with user data
module "ec2_prod" {
  source        = "./ec2"
  name          = "automated-prod"
  tags          = local.common_tags
  iam_role_name = module.iam.ec2_iam_role_name
  key_pair_name = var.key_pair_name
}