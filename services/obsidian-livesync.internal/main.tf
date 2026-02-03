terraform {
  backend "s3" {
    bucket = "tfstate-bucket"
    key = "obsidian-livesync.internal/terraform.tfstate"
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
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.16.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Bucket
resource "cloudflare_r2_bucket" "obsidian_livesync" {
  account_id = var.cloudflare_account_id
  name = "obsidian-livesync"
  location = "APAC"
  storage_class = "Standard"
}

# API Token
resource "cloudflare_api_token" "obsidian_livesync" {
  name = "obsidian-livesync"
  policies = [
    {
      effect = "allow",
      permission_groups = [
        {
          id = element(
            data.cloudflare_api_token_permission_groups_list.all.result,
            index(
              data.cloudflare_api_token_permission_groups_list.all.result.*.name,
              "Workers R2 Storage Bucket Item Read"
            )
          ).id
        },
        {
          id = element(
            data.cloudflare_api_token_permission_groups_list.all.result,
            index(
              data.cloudflare_api_token_permission_groups_list.all.result.*.name,
              "Workers R2 Storage Bucket Item Write"
            )
          ).id
        },
      ]
      resources = jsonencode({
        "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_default_${cloudflare_r2_bucket.obsidian_livesync.id}" = "*"
      })
    },
  ]
  status = "active"
}

data "cloudflare_api_token_permission_groups_list" "all" {}
