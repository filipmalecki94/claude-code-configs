# WordPress Conventions — Headless WooCommerce

## Security Checklist (Every API-facing Function)

Follow this order for every function that handles user input or modifies data:

1. **Nonce** — verify `wp_verify_nonce()` or REST nonce via `wp_rest` action
2. **Capability** — check `current_user_can()` before any privileged operation
3. **Sanitize** — `sanitize_text_field()`, `absint()`, `sanitize_email()`, etc. on ALL input
4. **Escape** — `esc_html()`, `esc_attr()`, `esc_url()` on ALL output (even in JSON, use `wp_json_encode()`)
5. **Prepared queries** — `$wpdb->prepare()` for ALL raw SQL. Never interpolate variables into queries.

## mu-plugin Conventions

### File naming
- Kebab-case: `{prefix}-graphql-extensions.php`, `{prefix}-wc-store-api-filters.php`
- Prefix with `{prefix}-` for project-specific mu-plugins

### Structure template
```php
<?php
/**
 * Plugin Name: App GraphQL Extensions
 * Description: Custom GraphQL fields and types for the storefront
 */

defined('ABSPATH') || exit;

/**
 * Register custom GraphQL fields.
 */
function app_register_graphql_fields(): void
{
    register_graphql_field('Product', 'customField', [
        'type' => 'String',
        'description' => 'A custom product field',
        'resolve' => function ($product) {
            return get_post_meta($product->databaseId, '_custom_field', true);
        },
    ]);
}
add_action('graphql_register_types', 'app_register_graphql_fields');
```

### Rules
- One concern per file — don't mix GraphQL extensions with WC filters
- No side effects at include time — all logic inside functions, registered via hooks
- Use PHP 8.4 features: typed properties, union types, named arguments, match expressions
- PSR-12 coding standard (braces on same line for control structures, next line for classes/methods)
- Prefix all function names with `app_` to avoid conflicts

## GraphQL Extension Patterns

### Register a custom field
```php
add_action('graphql_register_types', function (): void {
    register_graphql_field('Product', 'fieldName', [
        'type' => 'String',
        'resolve' => fn($product) => get_post_meta($product->databaseId, '_meta_key', true),
    ]);
});
```

### Register a custom type
```php
add_action('graphql_register_types', function (): void {
    register_graphql_object_type('CustomType', [
        'description' => 'A custom type',
        'fields' => [
            'id' => ['type' => 'ID'],
            'name' => ['type' => 'String'],
        ],
    ]);
});
```

### Modify existing resolver
```php
add_filter('graphql_resolve_field', function ($result, $source, $args, $context, $info) {
    if ($info->fieldName === 'price' && $source instanceof \WPGraphQL\WooCommerce\Model\Product) {
        // Modify price resolution
    }
    return $result;
}, 10, 5);
```

## WooCommerce REST/Store API Filter Patterns

### Modify Store API response
```php
add_filter('woocommerce_store_api_product_schema', function (array $schema): array {
    $schema['properties']['custom_field'] = [
        'description' => 'Custom field',
        'type' => 'string',
        'context' => ['view'],
    ];
    return $schema;
});
```

### Extend Store API endpoint data
```php
use Automattic\WooCommerce\StoreApi\Schemas\ExtendSchema;
use Automattic\WooCommerce\StoreApi\StoreApi;

add_action('woocommerce_blocks_loaded', function (): void {
    $extend = StoreApi::container()->get(ExtendSchema::class);
    $extend->register_endpoint_data([
        'endpoint' => 'cart/items',
        'namespace' => 'app',
        'data_callback' => fn() => ['custom' => 'value'],
        'schema_callback' => fn() => ['custom' => ['type' => 'string']],
    ]);
});
```

### WC REST API filter
```php
add_filter('woocommerce_rest_prepare_product_object', function ($response, $product, $request) {
    $response->data['custom_field'] = get_post_meta($product->get_id(), '_custom_field', true);
    return $response;
}, 10, 3);
```

## Hook Registration Rules

| Hook | When to Use |
|------|-------------|
| `init` | Register post types, taxonomies, rewrite rules |
| `rest_api_init` | Register custom REST endpoints |
| `graphql_register_types` | Register GraphQL fields, types, connections |
| `woocommerce_blocks_loaded` | Extend Store API (v3) |
| `woocommerce_init` | WooCommerce-specific initialization |
| `plugins_loaded` | Cross-plugin integration, translations |

## Domain Layer Conventions (DDD)

### Class Types

| Type | Pattern | Example |
|------|---------|---------|
| Value Object | `final readonly class` | `Price`, `Money`, `Sku`, `Email`, `Address` |
| Entity | `class` with readonly ID | `Product`, `Order`, `OrderLine` |
| Aggregate Root | Entity + domain event recording | `Product`, `Order` |
| Domain Event | `final readonly class implements DomainEvent` | `ProductCreated`, `OrderPlaced` |
| Repository | `interface` only in domain | `ProductRepositoryInterface` |
| Domain Service | `final class` for cross-entity operations | `PricingService` |
| Enum | `enum : string` | `OrderStatus`, `PaymentMethod` |

### Rules

- **Namespace**: `App\Domain\{BoundedContext}` (e.g., `App\Domain\Catalog`)
- **Location**: `web/app/mu-plugins/{project}-domain/src/{BoundedContext}/`
- **No WP/WC imports**: domain classes must NOT use `get_post_meta()`, `WC_Product`, `add_action()`, etc.
- **Self-validating VOs**: constructors throw `\InvalidArgumentException` on invalid data
- **Immutable VOs**: always `final readonly class`, compared with `equals()` method
- **One Repository per Aggregate Root**: interface in domain, implementation in infrastructure mu-plugin
- **Domain Events**: recorded on Aggregate Root via `recordEvent()`, dispatched in Application layer via `do_action()`

### Autoloading

The `{project}-domain.php` mu-plugin loader registers a PSR-4 autoloader:
- Namespace prefix: `App\Domain\`
- Base directory: `__DIR__ . '/src/'`

### Testing

Domain classes are **pure PHP** — test with plain PHPUnit assertions, no Brain Monkey needed. Test directory: `tests/Unit/Domain/`.

## Composer Workflow

- **Never** edit files in `vendor/`, `web/wp/`, or `web/app/plugins/` directly
- Add plugins: edit `composer.json` → run `docker compose run --rm wordpress composer require vendor/package:^version`
- Update plugins: `docker compose run --rm wordpress composer update vendor/package`
- Check for vulnerabilities: `docker compose run --rm wordpress composer audit`
- Validate: `docker compose run --rm wordpress composer validate`
