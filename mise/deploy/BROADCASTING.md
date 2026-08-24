# Broadcaster deployment runbook

The checked-in configuration intentionally has `broadcasting.enabled: false`. Cloudflare R2 is the authoritative delivery ledger; `.maverick-data` is only an encrypted local cache.

## First deployment

1. Create the private `maverick-state` R2 bucket and a token restricted to Object Read & Write for that bucket.
2. Create a 32-byte encryption key, for example `openssl rand -base64 32`, and store it separately from R2 in the `Maverick Broadcast` item in the custom 1Password vault `jsorge.net`.
3. Add fields to that item matching every filename listed in `provision_broadcast_secrets.sh`. The Bluesky value is an app password. The Mastodon token needs `write:statuses`. The LinkedIn app redirect URI is `https://jsorge.net/_admin/broadcast/linkedin/callback`.
4. Validate that every field can be read. This does not print values, create secret files, or use `sudo`. For an interactive local check, sign in to the CLI:

   ```sh
   eval $(op signin)
   mise run broadcast-secrets-check
   ```

   For the server, give a service account read-only item access to the custom `jsorge.net` vault, provide its token without committing it, and run the same check:

   ```sh
   export OP_SERVICE_ACCOUNT_TOKEN='...'
   mise run broadcast-secrets-check
   ```

   The default item reference is `op://jsorge.net/Maverick Broadcast`. Set `OP_MAVERICK_ITEM` only if the vault or item is renamed.
5. The GitHub Actions secret `ONE_PASSWORD_TOKEN` contains the service-account token. The manual **Restart Blog** workflow sends it to the server over SSH standard input, maps it to `OP_SERVICE_ACCOUNT_TOKEN` only for provisioning, installs the secret files, removes the token from the remote shell environment, and restarts the services. It never passes the token in the SSH command line or into the Maverick container.

   For a manual server-side deployment, authenticate with `OP_SERVICE_ACCOUNT_TOKEN` and run:

   ```sh
   cd /var/www/jsorge.net
   mise run broadcast-secrets-install
   mise run serve
   ```

6. Visit `https://jsorge.net/_admin/broadcast`, initialize the existing-post baseline, and verify that R2 revision 1 appears. Test Bluesky and Mastodon and connect LinkedIn.
7. Preview posts, disable Micro.blog cross-posting, change `broadcasting.enabled` to `true`, and deploy. Do not remove the Micro.blog feed ping unless it is no longer wanted.

The origin must trust `X-Forwarded-Proto` only from Cloudflare; restrict direct origin access with the DigitalOcean firewall or use Cloudflare authenticated origin pulls. Maverick rejects production admin requests that are not reported as HTTPS.

## Replacement server

1. Leave `broadcasting.enabled: false` in the deployed revision.
2. Restore the same 1Password fields with `provision_broadcast_secrets.sh`. The encryption key must be the original key.
3. Start the stack. Do not copy `.maverick-data`; copying it is an optional cache optimization only.
4. Open the broadcaster admin. Confirm that `R2 state is healthy` and that its revision matches the old server. If restoration or decryption fails, stop here—the site stays available and broadcasting remains fail-closed.
5. Test every provider connection. Reconnect LinkedIn if its token is expired.
6. Deploy the revision that sets `broadcasting.enabled: true`.

Never delete `jsorge.net/latest.json` or create a new baseline as a recovery shortcut. Use the admin snapshot list to restore an earlier verified immutable revision if the latest snapshot is damaged.

## R2 smoke test

Use a disposable `keyPrefix`, keep automatic delivery disabled, initialize the baseline, restart with an empty `.maverick-data` directory, and confirm the same revision is restored. Then test a snapshot restore from the admin page. A test-prefix cleanup is intentionally manual because snapshots are immutable and deletion is destructive.
