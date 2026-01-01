terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.12.0"
    }
  }
}

provider cloudflare {
  api_token = var.cloudflare_api_token
}

# Bucket
resource "cloudflare_r2_bucket" "tfstate_bucket" {
  account_id = var.cloudflare_account_id
  name = "tfstate-bucket"
  location = "APAC"
}

# API Token
resource "cloudflare_api_token" "tfstate_sync" {
  name = "tfstate-sync"
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
      resources = {
        "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_default_${cloudflare_r2_bucket.tfstate_bucket.id}" = "*"
      }
    },
  ]
  expires_on = "2027-01-01T00:00:00Z"
  status = "active"
}

data "cloudflare_api_token_permission_groups_list" "all" {}
