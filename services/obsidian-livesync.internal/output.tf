output "endpoint" {
  value = "${var.cloudflare_account_id}.r2.cloudflarestorage.com"
}

output "bucket_name" {
  value = cloudflare_r2_bucket.obsidian_livesync.name
}

output "access_key" {
  value = cloudflare_api_token.obsidian_livesync.id
}

output "secret_key" {
  value = sha256(cloudflare_api_token.obsidian_livesync.value)
  sensitive = true
}
