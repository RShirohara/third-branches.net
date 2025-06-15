# `third-branches.net`

Service and deployment definitions for `third-branches.net`.

## Requirements

- Cloudflare
  - Account ID (`cloudflare_account_id`)
  - API Token (`cloudflare_api_token`)
    - Token Name: `terraform-deploy`
    - Template: "Create Additional Tokens"
    - Permissions:
      - Account: Workers R2 Storage: Edit
      - User: API Tokens: Edit
      - Zone: Bot Management: Edit
      - Zone: Zone: Edit
      - Zone: DNS: Edit
    - Account Resources:
      - Include: Third Branches
    - Zone Resources
      - Include: All zones from an account: Third Branches
