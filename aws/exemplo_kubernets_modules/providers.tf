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
    # Caso queira compartilhar entre outros colaboradores para editar o mesmo ambiente, manda o tfstate para o S3
    
    # backend "s3" {
    #     bucket         = "lucas-terraform-state"
    #     key            = "kubernetes/terraform.tfstate"
    #     region         = "us-east-1"
    #     profile        = "lucas-admin"
    #     encrypt        = true
    #     dynamodb_table = "terraform-locks"
      
    # }
}

provider "aws" {
  region = "us-east-1"
  profile = "lucas-admin"
}
