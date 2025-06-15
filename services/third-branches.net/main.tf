terraform {
  backend "s3" {
    bucket                      = "tfstate-bucket"
    key                         = "third-branches.net/terraform.tfstate"
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

# Zone
resource "cloudflare_zone" "third_branches" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "third-branches.net"
  type = "full"
}

resource "cloudflare_zone_dnssec" "third_branches" {
  zone_id = cloudflare_zone.third_branches.id
  status = "active"
}

resource "cloudflare_bot_management" "third_branches" {
  zone_id = cloudflare_zone.third_branches.id
  ai_bots_protection = "block"
}

# Domain
# Memo: Cannot Import

# DNS Record
resource "cloudflare_dns_record" "keyoxide_dns_9C22B2503BDD9E049728C5432C773681151FDE8F" {
  name = "third-branches.net"
  ttl = 1
  type = "TXT"
  zone_id = cloudflare_zone.third_branches.id
  comment = "OpenPGP Hashed Proof"
  content = "$2a$11$hT9pZ2V2qPpZdmChREXSru6W2c0YjJphGTbFb8i/BGWe5MXEOFxZK"
}

resource "cloudflare_dns_record" "protonmail_verify" {
  name = "third-branches.net"
  ttl = 1
  type = "TXT"
  zone_id = cloudflare_zone.third_branches.id
  comment = "ProtonMail Custom Domain: Verification."
  content = "protonmail-verification=a0ae0f76af9c777ff0c4441923de4bbd3ca9282b"
}

resource "cloudflare_dns_record" "protonmail_mx_mail" {
  name = "third-branches.net"
  ttl = 1
  type = "MX"
  zone_id = cloudflare_zone.third_branches.id
  comment = "ProtonMail Custom Domain: MX Lookup."
  content = "mail.protonmail.ch"
  priority = 10
}

resource "cloudflare_dns_record" "protonmail_mx_mailsec" {
  name = "third-branches.net"
  ttl = 1
  type = "MX"
  zone_id = cloudflare_zone.third_branches.id
  comment = "ProtonMail Custom Domain: MX Lookup."
  content = "mailsec.protonmail.ch"
  priority = 20
}

resource "cloudflare_dns_record" "protonmail_spf" {
  name = "third-branches.net"
  ttl = 1
  type = "TXT"
  zone_id = cloudflare_zone.third_branches.id
  comment = "ProtonMail Custom Domain: SPF Record."
  content = "v=spf1 include:_spf.protonmail.ch ~all"
}

resource "cloudflare_dns_record" "protonmail_dkim_first" {
  name = "protonmail._domainkey.third-branches.net"
  ttl = 1
  type = "CNAME"
  zone_id = cloudflare_zone.third_branches.id
  comment = "ProtonMail Custom Domain: DKIM Signature."
  content = "protonmail.domainkey.dv3gi3gofnzhmybfv33o2wflbvqyibalykolo5jd43nbldary6k4a.domains.proton.ch"
}

resource "cloudflare_dns_record" "protonmail_dkim_second" {
  name = "protonmail2._domainkey.third-branches.net"
  ttl = 1
  type = "CNAME"
  zone_id = cloudflare_zone.third_branches.id
  comment = "ProtonMail Custom Domain: DKIM Signature."
  content = "protonmail2.domainkey.dv3gi3gofnzhmybfv33o2wflbvqyibalykolo5jd43nbldary6k4a.domains.proton.ch"
}

resource "cloudflare_dns_record" "protonmail_dkim_third" {
  name = "protonmail3._domainkey.third-branches.net"
  ttl = 1
  type = "CNAME"
  zone_id = cloudflare_zone.third_branches.id
  comment = "ProtonMail Custom Domain: DKIM Signature."
  content = "protonmail3.domainkey.dv3gi3gofnzhmybfv33o2wflbvqyibalykolo5jd43nbldary6k4a.domains.proton.ch"
}

resource "cloudflare_dns_record" "protonmail_dmarc" {
  name = "_dmarc.third-branches.net"
  ttl = 1
  type = "TXT"
  zone_id = cloudflare_zone.third_branches.id
  comment = "ProtonMail Custom Domain: DMARC policy."
  content = "v=DMARC1; p=quarantine"
}
