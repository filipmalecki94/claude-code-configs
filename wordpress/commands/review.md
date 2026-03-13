---
description: Code review PHP files — security, conventions, headless API patterns
argument: Optional file paths or git ref (default: changed .php files)
---

Perform a code review of PHP files in the WordPress headless backend.

## Behavior

1. **Determine scope:**
   - If `$ARGUMENTS` contains file paths — review those files
   - If `$ARGUMENTS` contains a git ref — review files changed since that ref
   - If empty — review uncommitted changes: `git diff HEAD -- '*.php'`

2. **Read all PHP files in scope** from:
   - `web/app/mu-plugins/`
   - `web/app/themes/missio-headless/`
   - `config/`

3. **Apply review checklist:**

   **Security (CRITICAL):**
   - ABSPATH guard on every mu-plugin
   - Input sanitization (sanitize_text_field, absint, etc.)
   - Output escaping (esc_html, esc_attr, wp_json_encode)
   - $wpdb->prepare() on all raw SQL
   - Nonce verification on mutations
   - current_user_can() on privileged operations

   **PHP Quality:**
   - PSR-12 compliance
   - PHP 8.4 typed properties, return types
   - declare(strict_types=1)
   - No dead code or commented-out code

   **WordPress/WooCommerce Patterns:**
   - Correct hook registration and priorities
   - Filters always return a value
   - GraphQL resolvers return correct types
   - REST endpoints have permission_callback
   - No direct DB queries for WC data (use WC API)

   **Headless API:**
   - GraphQL fields have descriptions
   - No HTML output or wp_redirect in API context
   - JSON responses via WP_REST_Response

4. **Report findings** with severity: CRITICAL / WARNING / SUGGESTION

5. **Summarize:** count by severity, top 3 priorities, overall assessment
