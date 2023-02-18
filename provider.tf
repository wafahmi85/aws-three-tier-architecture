provider "aws" {
    shared_credentials_files = ["~/.aws/credentials"]
    region = var.region
}

terraform {
  required_version = ">= 1.3.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.55.0"
    }
  }
}