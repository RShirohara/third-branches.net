terraform {
  backend "s3" {
    bucket                      = "tfstate-bucket"
    key                         = "navidrome.third-branches.net/terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true

    access_key = var.terraform_backend_access_key
    secret_key = var.terraform_backend_secret_key
    endpoints = {
      s3 = var.terraform_backend_endpoint_s3_url
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.17.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# DNS Record
resource "cloudflare_dns_record" "navidrome" {
  name    = "navidrome.third-branches.net"
  ttl     = 1
  type    = "CNAME"
  zone_id = var.cloudflare_zone_id
  content = "${cloudflare_zero_trust_tunnel_cloudflared.navidrome.id}.cfargotunnel.com"
  proxied = true
}

# Reverse Proxy
resource "cloudflare_zero_trust_tunnel_cloudflared" "navidrome" {
  account_id    = var.cloudflare_account_id
  name          = "navidrome"
  tunnel_secret = random_id.tunnel_secret.b64_std
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "navidrome" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.navidrome.id
  config = {
    ingress = [
      {
        hostname = cloudflare_dns_record.navidrome.name
        service  = "http://systemd-navidrome-app:4533"
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

data "cloudflare_zero_trust_tunnel_cloudflared_token" "navidrome" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.navidrome.id
}
