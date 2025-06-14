# `tfstate.internal`

The S3 compatible bucket to manages tfstate for all services in the `third-branches.net` domain.

## Requirements

- Cloudflare Account ID (`cloudflare_account_id`)
- Cloudflare API Token (`cloudflare_api_token`)
  - Token Name: `tfstate-deploy`
  - Template:
    - Create Additional Tokens
  - Permissions:
    - Account: Workers R2 Storage: Edit
    - User: API Tokens: Edit
  - Account Resources:
    - Include: Third Branches
