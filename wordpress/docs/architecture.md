# Architecture — Headless WooCommerce on Bedrock

## Overview

This is a **headless WordPress backend** — it serves no HTML to end users. All frontend rendering is handled by Next.js. WordPress provides:
- WooCommerce e-commerce engine (products, orders, payments, shipping)
- Content management (pages, posts, media)
- 4 API layers consumed by Next.js

## What's in Git vs What Docker/Composer Provides

**In git**: `composer.json`, `config/`, `web/app/mu-plugins/`, `web/app/themes/{project}-headless/`, Dockerfile
**NOT in git** (generated): `vendor/`, `web/wp/`, `web/app/plugins/` (Composer-installed), `web/app/uploads/`

Never edit files in `vendor/`, `web/wp/`, or `web/app/plugins/` — they are Composer-managed.

## Bedrock Structure

```
wordpress/
├── composer.json              # ALL dependencies declared here
├── config/
│   ├── application.php        # Main config — reads .env, defines constants
│   └── environments/
│       ├── development.php    # WP_DEBUG=true, SAVEQUERIES, etc.
│       └── production.php     # Hardened settings
└── web/                       # Webroot (Nginx document_root)
    ├── wp/                    # WordPress core (Composer, never edit)
    └── app/                   # Replaces wp-content/
        ├── mu-plugins/        # Must-use plugins (auto-loaded, our code)
        ├── plugins/           # Composer-managed plugins (never edit)
        ├── themes/
        │   └── {project}-headless/  # Minimal headless theme
        └── uploads/           # Media (Docker named volume)
```

## 4 API Layers

| Layer | Endpoint | Auth | Used For |
|-------|----------|------|----------|
| WPGraphQL | `POST /graphql` | Optional JWT | Products, categories, posts, SEO data (SSR/SSG) |
| WC Store API v3 | `/wp-json/wc/store/v3/` | Nonce (browser) | Cart, checkout, shipping (client-side) |
| WP REST API | `/wp-json/wp/v2/` | Optional JWT | Pages, posts, media |
| WC REST API | `/wp-json/wc/v3/` | JWT (server) | Order management, reports (server-side only) |

## mu-plugin Conventions

All custom PHP code lives in `web/app/mu-plugins/`. Each mu-plugin:
1. Starts with `<?php` and ABSPATH guard: `defined('ABSPATH') || exit;`
2. Uses kebab-case filename: `{prefix}-graphql-extensions.php`
3. Wraps logic in functions, registers via hooks — no side effects at include time
4. Follows PSR-12 coding standard (not WordPress coding standard)

## Docker Execution Context

The `docker-compose.yml` lives in the **parent directory** (`{DOCKER_DIR}/`), not in `wordpress/`. All Docker commands must be run from there:

```bash
cd {DOCKER_DIR} && docker compose run --rm wpcli wp ...
cd {DOCKER_DIR} && docker compose run --rm wordpress composer ...
```

The `wordpress/` directory is bind-mounted into the container at `/var/www/html`.

## Redis Object Cache

- Plugin: `redis-cache` (Composer-managed)
- Config: `WP_REDIS_HOST=redis`, `WP_REDIS_PORT=6379` (in `config/application.php`)
- Reduces MySQL load significantly under concurrent API requests
- Must be enabled: `docker compose run --rm wpcli wp redis enable`

## JWT Authentication

- Plugin: `wp-graphql-jwt-authentication`
- Secret: `GRAPHQL_JWT_AUTH_SECRET_KEY` constant (from `.env` → `JWT_AUTH_SECRET_KEY`)
- Used for: authenticated GraphQL queries, WC REST API calls from Next.js server-side
- Tokens issued via GraphQL `login` mutation or REST endpoint

## Key Constants (config/application.php)

| Constant | Source | Purpose |
|----------|--------|---------|
| `WP_HOME` | `.env` | Frontend URL (Nginx) |
| `WP_SITEURL` | `.env` | WordPress core URL |
| `CONTENT_DIR` | hardcoded `/app` | Custom content directory |
| `GRAPHQL_JWT_AUTH_SECRET_KEY` | `.env` | JWT signing secret |
| `WP_REDIS_HOST` | `.env` / `redis` | Redis hostname |
| `WP_DEFAULT_THEME` | hardcoded | `{project}-headless` |

## Domain Layer (DDD)

The project uses Domain-Driven Design for core business logic. Domain classes are framework-agnostic PHP — no WordPress or WooCommerce imports.

### Directory Structure

```
web/app/mu-plugins/{project}-domain/
├── {project}-domain.php              # mu-plugin loader (autoloader registration)
├── src/
│   ├── Catalog/
│   │   ├── Product.php            # Aggregate Root
│   │   ├── ProductVariant.php     # Entity
│   │   ├── Price.php              # Value Object
│   │   ├── Sku.php                # Value Object
│   │   ├── ProductRepositoryInterface.php
│   │   └── Events/
│   │       └── ProductCreated.php
│   ├── Order/
│   │   ├── Order.php              # Aggregate Root
│   │   ├── OrderLine.php          # Entity
│   │   ├── OrderStatus.php        # Enum
│   │   └── Events/
│   ├── Shared/
│   │   ├── Money.php              # Shared Value Object
│   │   ├── Address.php            # Shared Value Object
│   │   └── DomainEvent.php        # Base interface
│   └── {Context}/                 # Other bounded contexts
```

### Namespace Convention

`App\Domain\{BoundedContext}` — e.g., `App\Domain\Catalog`, `App\Domain\Order`, `App\Domain\Shared`.

### Architecture Layers

```
Domain Layer ({project}-domain/)        ← Pure PHP, no WP/WC dependencies
    ↑ used by
Application Layer (mu-plugins)       ← Orchestration, use cases, WP hooks
    ↑ used by
Infrastructure Layer (mu-plugins)    ← Repository implementations wrapping WC_Product, WC_Order, etc.
    ↑ called from
API Layer (GraphQL, REST, Store API) ← Existing 4 API layers
```

Domain classes define interfaces (e.g., `ProductRepositoryInterface`). Infrastructure implementations use WooCommerce functions (`wc_get_product()`, `WC_Order`, etc.) and are registered via `mu-plugins`.

### Agent Workflow

1. `ddd-modeler` — generates domain model and class skeletons
2. `wp-architecture-planner` — plans integration with WooCommerce
3. `wp-api-developer` — implements repository classes and `// TODO:` bodies

## Composer Dependency Management

- All plugins installed via Composer — never install plugins through WP admin
- Versions are **pinned** in `composer.json` — critical for WPGraphQL ↔ WooCommerce compatibility
- Update workflow: change version in `composer.json` → `docker compose run --rm wordpress composer update` → test → commit
- `composer.lock` is committed to ensure reproducible builds
