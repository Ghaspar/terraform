terraform {
    required_version = ">=1.5.7"
    required_providers {
        local = {
        source  = "hashicorp/local"
        version = "~> 2.0"
        }
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}

provider "aws" {
  region = "us-east-1"
  profile = "lucas-admin"
}
