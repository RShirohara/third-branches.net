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
resource "aws_lightsail_database" "gotosocial" {
  relational_database_name = "gotosocial-db"
  availability_zone = data.aws_availability_zones.availability_zone.names[0]
  master_database_name = "gotosocial"
  master_username = "gotosocial"
  master_password = random_password.db_password.result
  blueprint_id = "postgres_15"
  bundle_id = "micro_2_0"
  preferred_backup_window = "18:00-19:00"
  backup_retention_enabled = true
  final_snapshot_name  = "gotosocial-db-delete-${random_string.db_snapshot.id}"
  skip_final_snapshot = true
  tags = {
    service = "gotosocial"
  }
}

resource "random_password" "db_password" {
  length = 64
  special = false
}

resource "random_string" "db_snapshot" {
  length = 8
  special = false
  upper = false
}

data "aws_availability_zones" "availability_zone" {
  state = "available"
}

# DNS Record
resource "cloudflare_dns_record" "gotosocial" {
  name = "ap.third-branches.net"
  ttl = 1
  type = "CNAME"
  zone_id = var.cloudflare_zone_id
  content = "${cloudflare_zero_trust_tunnel_cloudflared.gotosocial.id}.cfargotunnel.com"
  proxied = true
}

# Media Bucket
resource "cloudflare_r2_bucket" "gotosocial_media" {
  account_id = var.cloudflare_account_id
  name = "gotosocial-media"
  location = "APAC"
  storage_class = "Standard"
}

resource "cloudflare_api_token" "gotosocial_media" {
  name = "gotosocial-media"
  policies = [
    {
      effect = "allow"
      permission_groups = [
        {
          id = element(
            data.cloudflare_api_token_permission_groups_list.all.result,
            index(
              data.cloudflare_api_token_permission_groups_list.all.result.*.name,
              "Workers R2 Storage Bucket Item Write"
            )
          ).id
        },
        {
          id = element(
            data.cloudflare_api_token_permission_groups_list.all.result,
            index(
              data.cloudflare_api_token_permission_groups_list.all.result.*.name,
              "Workers R2 Storage Bucket Item Read"
            )
          ).id
        },
      ]
      resources = {
        "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_default_${cloudflare_r2_bucket.gotosocial_media.id}" = "*"
      }
    },
    {
      effect = "allow"
      permission_groups = [
        {
          id = element(
            data.cloudflare_api_token_permission_groups_list.all.result,
            index(
              data.cloudflare_api_token_permission_groups_list.all.result.*.name,
              "Workers R2 Storage Read"
            )
          ).id
        }
      ],
      resources = {
        "com.cloudflare.api.account.${var.cloudflare_account_id}" = "*"
      }
    }
  ]
  status = "active"
}

data "cloudflare_api_token_permission_groups_list" "all" {}

# Reverse Proxy
resource "cloudflare_zero_trust_tunnel_cloudflared" "gotosocial" {
  account_id = var.cloudflare_account_id
  name = "gotosocial"
  tunnel_secret = random_id.tunnel_secret.b64_std
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "gotosocial" {
  account_id = var.cloudflare_account_id
  tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.gotosocial.id
  config = {
    ingress = [
      {
        hostname = cloudflare_dns_record.gotosocial.name
        service = "http://localhost:8080"
      },
      {
        service = "http_status:404"
      }
    ]
    warp_routing = {
      enabled = false
    }
  }
  source = "cloudflare"
}

resource "random_id" "tunnel_secret" {
  byte_length = 35
}
