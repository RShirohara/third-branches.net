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
      version = "6.27.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.16.0"
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
resource "aws_lightsail_container_service" "gotosocial" {
  name = "gotosocial-service"
  power = "micro"
  scale = 1
  tags = {
    service = "gotosocial"
  }
}

resource "aws_lightsail_container_service_deployment_version" "gotosocial" {
  service_name = aws_lightsail_container_service.gotosocial.name

  container {
    container_name = "app"
    image = "superseriousbusiness/gotosocial:0.20.2"
    environment = {
      SERVICE_CON = "service://localhost"
      TZ = "Asia/Tokyo"
      GTS_HOST = cloudflare_dns_record.gotosocial.name
      GTS_PORT = "8080"
      GTS_DB_TYPE = "postgres"
      GTS_DB_ADDRESS = aws_lightsail_database.gotosocial.master_endpoint_address
      GTS_DB_USER = "gotosocial"
      GTS_DB_PASSWORD = random_password.db_password.result
      GTS_DB_DATABASE = "gotosocial"
      GTS_DB_TLS_MODE = "enable"
      GTS_ACCOUNTS_REGISTRATION_OPEN = "false"
      GTS_STORAGE_BACKEND = "s3"
      GTS_STORAGE_S3_ENDPOINT = "${var.cloudflare_account_id}.r2.cloudflarestorage.com"
      GTS_STORAGE_S3_ACCESS_KEY = cloudflare_api_token.gotosocial_media.id
      GTS_STORAGE_S3_SECRET_KEY = sha256(cloudflare_api_token.gotosocial_media.value)
      GTS_STORAGE_S3_BUCKET = "gotosocial-media"
      GTS_LETSENCRYPT_ENABLED = "false"
      GTS_INSTANCE_INJECT_MASTODON_VERSION = "true"
    }
  }
  container {
    container_name = "tunnel"
    image = "cloudflare/cloudflared:2025.11.1"
    command = ["tunnel", "run"]
    environment = {
      SERVICE_CON = "service://localhost"
      TUNNEL_TOKEN = data.cloudflare_zero_trust_tunnel_cloudflared_token.gotosocial.token
    }
  }
}

# DB Instance
resource "aws_lightsail_database" "gotosocial" {
  relational_database_name = "gotosocial-db"
  availability_zone = data.aws_availability_zones.availability_zone.names[0]
  master_database_name = "gotosocial"
  master_username = "gotosocial"
  master_password = random_password.db_password.result
  blueprint_id = "postgres_17"
  bundle_id = "micro_2_0"
  preferred_backup_window = "17:00-18:00"
  preferred_maintenance_window = "fri:18:30-fri:19:30"
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
      resources = jsonencode({
        "com.cloudflare.edge.r2.bucket.${var.cloudflare_account_id}_default_${cloudflare_r2_bucket.gotosocial_media.id}" = "*"
      })
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
      resources = jsonencode({
        "com.cloudflare.api.account.${var.cloudflare_account_id}" = "*"
      })
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
}

resource "random_id" "tunnel_secret" {
  byte_length = 35
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "gotosocial" {
  account_id = var.cloudflare_account_id
  tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.gotosocial.id
}
