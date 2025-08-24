terraform {
  backend "s3" {
    bucket = "tfstate-bucket"
    key = "jellyfin.third-branches.net/terraform.tfstate"
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
      version = "5.7.1"
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

# DNS Record
resource "cloudflare_dns_record" "jellyfin" {
  name = "jellyfin.third-branches.net"
  ttl = 1
  type = "CNAME"
  zone_id = var.cloudflare_zone_id
  content = "${cloudflare_zero_trust_tunnel_cloudflared.jellyfin.id}.cfargotunnel.com"
  proxied = true
}

# Reverse Proxy
resource "cloudflare_zero_trust_access_application" "jellyfin" {
  zone_id = var.cloudflare_zone_id
  allow_authenticate_via_warp = true
  destinations = [
    {
      type = "public"
      uri = cloudflare_dns_record.jellyfin.name
    }
  ]
  logo_url = "https://raw.githubusercontent.com/jellyfin/jellyfin-ux/refs/heads/master/branding/SVG/banner-light.svg"
  name = "Jellyfin"
  policies = [
    {
      decision = "allow"
      include = [
        {
          email = {
            email = "jellyfin.third-branches.net.distract142@passmail.net"
          }
        }
      ]
      name = "Jellyfin: Mail OTP"
    }
  ]
  service_auth_401_redirect = true
  session_duration = "24h"
  type = "self_hosted"
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "jellyfin" {
  account_id = var.cloudflare_account_id
  name = "jellyfin"
  tunnel_secret = random_id.tunnel_secret.b64_std
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "jellyfin" {
  account_id = var.cloudflare_account_id
  tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.jellyfin.id
  config = {
    ingress = [
      {
        hostname = cloudflare_dns_record.jellyfin.name
        service = "http://jellyfin_app:8096"
      },
      {
        service = "http_status:404"
      }
    ]
    warp_routing = {
      enabled = true
    }
  }
}

resource "random_id" "tunnel_secret" {
  byte_length = 35
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "jellyfin" {
  account_id = var.cloudflare_account_id
  tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.jellyfin.id
}
