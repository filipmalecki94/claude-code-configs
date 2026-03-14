---
description: Composer validate + audit + outdated + WPGraphQL compatibility check
argument: Optional --update to also run composer update
---

Check Composer dependencies health for the WordPress headless backend.

## Behavior

Run the following checks in sequence:

1. **Validate composer.json:**
   ```bash
   cd {DOCKER_DIR} && docker compose run --rm wordpress composer validate
   ```

2. **Security audit:**
   ```bash
   cd {DOCKER_DIR} && docker compose run --rm wordpress composer audit
   ```

3. **Check outdated packages:**
   ```bash
   cd {DOCKER_DIR} && docker compose run --rm wordpress composer outdated --direct
   ```

4. **WPGraphQL compatibility check:**
   - Read composer.json to get current versions of:
     - `wpackagist-plugin/woocommerce`
     - `wp-graphql/wp-graphql`
     - `wp-graphql/wp-graphql-woocommerce`
   - Verify WPGraphQL for WooCommerce is compatible with current WooCommerce version
   - Check CHANGELOG or release notes if versions changed

5. **Report:**
   - Validation: pass/fail with issues
   - Security: vulnerabilities found (severity, advisory, affected package)
   - Outdated: packages with available updates
   - Compatibility: WPGraphQL ↔ WooCommerce matrix status
   - Recommendation: safe to update or not, with reasoning

6. **If `$ARGUMENTS` contains `--update`:**
   ```bash
   cd {DOCKER_DIR} && docker compose run --rm wordpress composer update
   ```
   Then re-run validation and audit to confirm no issues.
