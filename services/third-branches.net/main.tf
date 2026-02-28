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
      version = "5.17.0"
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
  crawler_protection = "disabled"
  enable_js = false
  fight_mode = false
  suppress_session_score = false
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

resource "cloudflare_dns_record" "keyoxide_dns_9A20FF47C3D9CCE2B0C980FF2A0B2ABA53BCBC12" {
  name = "third-branches.net"
  ttl = 1
  type = "TXT"
  zone_id = cloudflare_zone.third_branches.id
  comment = "OpenPGP Hashed Proof"
  content = "$2a$11$sMdLUduzVGVckvb6SyIGIOiUi2gs2yt73z3KI.KD3RN.sB6ApAmLS"
}

resource "cloudflare_dns_record" "protonmail_dkim_first" {
  name = "protonmail._domainkey.third-branches.net"
  ttl = 1
  type = "CNAME"
  zone_id = cloudflare_zone.third_branches.id
  comment = "Proton Mail: Domain keys"
  content = "protonmail.domainkey.dvme3lwzs7w5ah6qmu7xofcqtxebu46i23nx4z7nqy77hd4vzw3la.domains.proton.ch."
}

resource "cloudflare_dns_record" "protonmail_dkim_second" {
  name = "protonmail2._domainkey.third-branches.net"
  ttl = 1
  type = "CNAME"
  zone_id = cloudflare_zone.third_branches.id
  comment = "Proton Mail: Domain keys"
  content = "protonmail2.domainkey.dvme3lwzs7w5ah6qmu7xofcqtxebu46i23nx4z7nqy77hd4vzw3la.domains.proton.ch."
}

resource "cloudflare_dns_record" "protonmail_dkim_third" {
  name = "protonmail3._domainkey.third-branches.net"
  ttl = 1
  type = "CNAME"
  zone_id = cloudflare_zone.third_branches.id
  comment = "Proton Mail: Domain keys"
  content = "protonmail3.domainkey.dvme3lwzs7w5ah6qmu7xofcqtxebu46i23nx4z7nqy77hd4vzw3la.domains.proton.ch."
}

resource "cloudflare_dns_record" "protonmail_dmarc" {
  name = "_dmarc.third-branches.net"
  ttl = 1
  type = "TXT"
  zone_id = cloudflare_zone.third_branches.id
  comment = "Proton Mail: Message authentication reporting and conformance"
  content = "v=DMARC1; p=quarantine"
}

resource "cloudflare_dns_record" "protonmail_mx_first" {
  name = "third-branches.net"
  ttl = 1
  type = "MX"
  zone_id = cloudflare_zone.third_branches.id
  comment = "Proton Mail: Mail exchanger"
  priority = 10
  content = "mail.protonmail.ch"
}

resource "cloudflare_dns_record" "protonmail_mx_second" {
  name = "third-branches.net"
  ttl = 1
  type = "MX"
  zone_id = cloudflare_zone.third_branches.id
  comment = "Proton Mail: Mail exchanger"
  priority = 20
  content = "mailsec.protonmail.ch"
}

resource "cloudflare_dns_record" "protonmail_spf" {
  name = "third-branches.net"
  ttl = 1
  type =  "TXT"
  zone_id = cloudflare_zone.third_branches.id
  comment = "Proton Mail: Sender policy framework"
  content = "v=spf1 include:_spf.protonmail.ch ~all"
}

resource "cloudflare_dns_record" "protonmail_verification" {
  name = "third-branches.net"
  ttl = 1
  type =  "TXT"
  zone_id = cloudflare_zone.third_branches.id
  comment = "Proton Mail: DNS verification"
  content = "protonmail-verification=b058f104b647c106fd9e9fb1ec97de97166fbdab"
}

# Rulesets
resource "cloudflare_ruleset" "headers_replacement" {
  zone_id = cloudflare_zone.third_branches.id
  name = "third-branches.net: Header replacements"
  phase = "http_request_late_transform"
  kind = "zone"

  rules = [
    {
      description = "ap.third-branches.net: OverWrite user-agent for attachments"
      action = "rewrite"
      expression = "(http.request.full_uri wildcard \"https://ap.third-branches.net/fileserver/*\")"
      action_parameters = {
        headers = {
          User-Agent = {
            operation = "set"
            value = "Cloudflare"
          }
        }
      }
      enabled = true
    }
  ]
}
