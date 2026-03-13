---
description: Security audit — GraphQL, JWT, Store API, Stripe, secrets, OWASP
argument: Optional --full for complete audit, or file paths for targeted audit
---

Perform a security audit of the WordPress headless backend.

## Behavior

1. **Determine scope:**
   - `--full`: audit entire codebase (web/app/mu-plugins/, web/app/themes/, config/)
   - File paths: audit specific files
   - Empty: audit files changed since last commit

2. **Scan for hardcoded secrets:**
   - Search for API keys, passwords, tokens in source files
   - Check .env.example doesn't contain real values
   - Verify .env is in .gitignore

3. **Audit against 10 categories:**

   1. Input Validation & Sanitization
   2. Output Escaping
   3. Authentication & Authorization
   4. Nonce Verification
   5. File System Security
   6. Database Security
   7. Secrets Management
   8. CORS & Headers
   9. GraphQL Security (introspection, depth limiting, complexity)
   10. WooCommerce API Security (nonce, JWT, webhooks, price manipulation)

4. **Check configuration:**
   - `config/application.php` — debug settings, secret constants
   - `config/environments/production.php` — WP_DEBUG disabled, error display off

5. **Report findings:**
   - Severity: CRITICAL / HIGH / MEDIUM / LOW / INFO
   - Category (from 10 above)
   - Location: File:line
   - Description, Impact, Remediation

6. **Executive summary:** risk rating (1-10), prioritized fix plan
