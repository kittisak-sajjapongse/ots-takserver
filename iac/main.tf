terraform {
  required_version = ">= 1.3.0"

  backend "s3" {
    bucket = "jojjiw-tak-sandbox"
    key    = "ots-takserver/terraform.tfstate"
    region = "ap-southeast-7"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"
}

module "tak_server" {
  source             = "./modules/tak_server"
  vpc_id             = module.network.vpc_id
  subnet_id          = module.network.public_subnet_ids[0]
  instance_size      = var.instance_size
  ssd_size_gb        = var.ssd_size_gb
  admin_user         = var.admin_user
  admin_password     = var.admin_password
  user_data_template = "${path.module}/user_data/main.sh.tmpl"
}
