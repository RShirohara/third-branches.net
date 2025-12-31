# `third-branches.net`

Service and deployment definitions for `third-branches.net`.

## Requirements

- Amazon Web Service
  - IAM Policy: `PowerUserAccess`
- Cloudflare
  - Account ID (`cloudflare_account_id`)
  - API Token (`cloudflare_api_token`)
    - Token Name: `terraform-deploy`
    - Template: "Create Additional Tokens"
    - Permissions:
      - Account: Workers R2 Storage: Edit
      - Account: Cloudflare Tunnel: Edit
      - User: API Tokens: Edit
      - Zone: Transform Rules: Edit
      - Zone: Bot Management: Edit
      - Zone: Zone: Edit
      - Zone: DNS: Edit
    - Account Resources:
      - Include: Third Branches
    - Zone Resources
      - Include: All zones from an account: Third Branches
  - Zone ID (`cloudflare_zone_id`)
