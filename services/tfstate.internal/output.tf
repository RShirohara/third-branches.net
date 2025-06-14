output "endpoint" {
  value = "${var.cloudflare_account_id}.r2.cloudflarestorage.com"
}

output "access_key" {
  value = cloudflare_api_token.tfstate_sync.id
}

output "secret_key" {
  value = sha256(cloudflare_api_token.tfstate_sync.value)
  sensitive = true
}
