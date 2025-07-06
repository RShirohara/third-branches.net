# `ap.third-branches.net`

[GoToSocial](https://codeberg.org/superseriousbusiness/gotosocial) instance.

## Infrastructure

- App Hosting: AWS Lightsail Container
  - Power: `nano`
  - Scale: `1`
- DB: AWS Lightsail Database
  - Blueprint: PostgreSQL 15
  - Bundle: `micro`
- Media Hosting: Cloudflare R2
- Reverse Proxy: Cloudflare Tunnel
