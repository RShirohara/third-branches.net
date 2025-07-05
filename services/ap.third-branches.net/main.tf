terraform {
  backend "s3" {
    bucket = "tfstate-bucket"
    key = "ap.third-branches.net/terraform.tfstate"
    region = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
    skip_requesting_account_id = true
    skip_s3_checksum = true
    use_path_style = true

    access_key = var.terraform_backend_access_key
    secret_key = var.terraform_backend_secret_key
    endpoints = {
      s3 = var.terraform_backend_endpoint_s3_url
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.2.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.6.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# App Container

# DB Instance

# DNS Record

# Media Bucket

# Reverse Proxy
