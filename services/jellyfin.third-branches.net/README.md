# `jellyfin.third-branches.net`

[Jellyfin](https://jellyfin.org/) instance.

## Infrastructure

- App Hosting: Podman Compose
- Reverse Proxy: Cloudflare Tunnel

## Setup process

1. Run `make start` to start app container **without** settings up terraform resources.
2. Access `http://localhost:8096` to complete the setup.
3. Run `make stop` to stop app container.
4. Run `tofu apply --show-sensitive` to setup terraform resources.
    - check outputs `tunnel_token`.
5. Write environments variable to `./container/.env`.

    ```text
    TUNNEL_TOKEN=${`tofu apply`'s output}
    ```

6. Run `make start` to restart app container.
