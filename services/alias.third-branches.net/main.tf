terraform {
  backend "s3" {
    bucket                      = "tfstate-bucket"
    key                         = "alias.third-branches.net/terraform.tfstate"
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
      source = "cloudflare/cloudflare"
      version = "5.5.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# DNS
resource "cloudflare_dns_record" "protonpass_verify" {
  name = "alias.third-branches.net"
  ttl = 1
  type = "TXT"
  zone_id = var.cloudflare_zone_id
  comment = "Proton Pass Custom Domain: Verification."
  content = "pm-verification=kjylzcvneessiuukzmmzznghpsgvsl"
}

resource "cloudflare_dns_record" "protonpass_mx_mail" {
  name = "alias.third-branches.net"
  ttl = 1
  type = "MX"
  zone_id = var.cloudflare_zone_id
  comment = "Proton Pass Custom Domain: MX Lookup."
  content = "mx1.alias.proton.me"
  priority = 10
}

resource "cloudflare_dns_record" "protonpass_mx_mailsec" {
  name = "alias.third-branches.net"
  ttl = 1
  type = "MX"
  zone_id = var.cloudflare_zone_id
  comment = "Proton Pass Custom Domain: MX Lookup."
  content = "mx2.alias.proton.me"
  priority = 20
}

resource "cloudflare_dns_record" "protonpass_spf" {
  name = "alias.third-branches.net"
  ttl = 1
  type = "TXT"
  zone_id = var.cloudflare_zone_id
  comment = "Proton Pass Custom Domain: SPF Record."
  content = "v=spf1 include:alias.proton.me ~all"
}

resource "cloudflare_dns_record" "protonpass_dkim_first" {
  name = "dkim._domainkey.alias.third-branches.net"
  ttl = 1
  type = "CNAME"
  zone_id = var.cloudflare_zone_id
  comment = "Proton Pass Custom Domain: DKIM Signature."
  content = "dkim._domainkey.alias.proton.me"
}

resource "cloudflare_dns_record" "protonpass_dkim_second" {
  name = "dkim02._domainkey.alias.third-branches.net"
  ttl = 1
  type = "CNAME"
  zone_id = var.cloudflare_zone_id
  comment = "Proton Pass Custom Domain: DKIM Signature."
  content = "dkim02._domainkey.alias.proton.me"
}

resource "cloudflare_dns_record" "protonpass_dkim_third" {
  name = "dkim03._domainkey.alias.third-branches.net"
  ttl = 1
  type = "CNAME"
  zone_id = var.cloudflare_zone_id
  comment = "Proton Pass Custom Domain: DKIM Signature."
  content = "dkim03._domainkey.alias.proton.me"
}

resource "cloudflare_dns_record" "protonpass_dmarc" {
  name = "_dmarc.alias.third-branches.net"
  ttl = 1
  type = "TXT"
  zone_id = var.cloudflare_zone_id
  comment = "Proton Pass Custom Domain: DMARC policy."
  content = "v=DMARC1; p=quarantine; pct=100; adkim=s; aspf=s"
}
