Validate .env file against .env.example and check for common issues.

Steps:

1. **File existence**: Check that both `.env` and `.env.example` exist
   - If `.env` is missing, warn and suggest `cp .env.example .env`

2. **Missing variables**: Compare keys in `.env.example` vs `.env`
   - Report any keys present in `.env.example` but missing from `.env`

3. **Placeholder detection**: Scan `.env` values for unfilled placeholders:
   - Empty values: `KEY=`
   - Common placeholders: `changeme`, `your_*_here`, `REPLACE_ME`, `xxx`, `TODO`
   - Stripe test patterns that look unfilled: `pk_test_xxx`, `sk_test_xxx`
   - Default/example values that match `.env.example` exactly (likely not customized)

4. **Service hostname validation**: Verify Docker-internal hostnames:
   - `DB_HOST` should be `mysql` (not `localhost` or `127.0.0.1`)
   - `REDIS_URL` should contain `redis://redis:6379` (not `localhost`)
   - `NEXT_PUBLIC_WP_URL` should reference `nginx` or the external domain (not `localhost:9000`)

5. **Security checks**:
   - WordPress salts should be unique (not default/placeholder)
   - `JWT_AUTH_SECRET_KEY` should be set and not a placeholder
   - `NEXTAUTH_SECRET` should be set
   - No secrets should be the same value

6. **Report**: Present results as:
   - **OK**: properly configured variables (count only, don't list)
   - **MISSING**: variables not in .env
   - **PLACEHOLDER**: variables with unfilled placeholder values
   - **WRONG HOST**: variables using localhost instead of Docker service names
   - **SECURITY**: weak or duplicate secrets
