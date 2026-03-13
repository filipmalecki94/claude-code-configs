# Testing — Headless WooCommerce

## Stack

- **PHPUnit 10+** — unit test framework
- **Brain Monkey** — WordPress function mocking (hooks, filters, options)
- **Mockery** — general PHP mocking library (used by Brain Monkey)

## Docker Commands

```bash
# Run full test suite
cd /home/fifi/Documents/Projects/missio/missio-docker && \
  docker compose run --rm wpcli bash -c "cd /var/www/html && php vendor/bin/phpunit"

# Run single test file
cd /home/fifi/Documents/Projects/missio/missio-docker && \
  docker compose run --rm wpcli bash -c "cd /var/www/html && php vendor/bin/phpunit tests/Unit/MuPlugin/GraphqlExtensionsTest.php"

# Run with filter (specific test method)
cd /home/fifi/Documents/Projects/missio/missio-docker && \
  docker compose run --rm wpcli bash -c "cd /var/www/html && php vendor/bin/phpunit --filter testCustomFieldRegistration"

# Run with coverage
cd /home/fifi/Documents/Projects/missio/missio-docker && \
  docker compose run --rm wpcli bash -c "cd /var/www/html && php vendor/bin/phpunit --coverage-text"
```

## Directory Structure

```
wordpress/
├── phpunit.xml
└── tests/
    └── Unit/
        ├── MuPlugin/
        │   ├── GraphqlExtensionsTest.php
        │   ├── WcStoreApiFiltersTest.php
        │   └── MissioHelpersTest.php
        ├── Theme/
        │   └── FunctionsTest.php
        └── bootstrap.php
```

## Test Class Template

```php
<?php

declare(strict_types=1);

namespace Tests\Unit\MuPlugin;

use PHPUnit\Framework\TestCase;
use Brain\Monkey;
use Brain\Monkey\Functions;

class GraphqlExtensionsTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        Monkey\setUp();
    }

    protected function tearDown(): void
    {
        Monkey\tearDown();
        parent::tearDown();
    }

    public function testCustomGraphqlFieldIsRegistered(): void
    {
        Functions\expect('register_graphql_field')
            ->once()
            ->with('Product', 'customField', \Mockery::type('array'));

        // Include the mu-plugin file to trigger hook registration
        // Then fire the action
        do_action('graphql_register_types');
    }

    public function testResolverReturnsSanitizedValue(): void
    {
        Functions\expect('get_post_meta')
            ->once()
            ->with(42, '_custom_field', true)
            ->andReturn('<script>alert("xss")</script>');

        Functions\expect('sanitize_text_field')
            ->once()
            ->andReturnUsing(fn($v) => strip_tags($v));

        // Test the resolver function directly
        $result = missio_resolve_custom_field(42);
        $this->assertStringNotContainsString('<script>', $result);
    }
}
```

## Domain Layer Tests (Pure PHPUnit — No Brain Monkey)

Domain classes (`Missio\Domain\*`) are framework-agnostic PHP. They do NOT need Brain Monkey or WordPress function mocking.

### Directory

```
tests/Unit/Domain/
├── Catalog/
│   ├── PriceTest.php
│   ├── ProductTest.php
│   └── SkuTest.php
├── Order/
│   ├── OrderTest.php
│   └── OrderStatusTest.php
└── Shared/
    ├── MoneyTest.php
    └── AddressTest.php
```

### Template

```php
<?php
declare(strict_types=1);

namespace Tests\Unit\Domain\Catalog;

use PHPUnit\Framework\TestCase;
use Missio\Domain\Catalog\Price;

class PriceTest extends TestCase
{
    public function testCannotCreateNegativePrice(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        new Price(amountInCents: -100, currency: 'PLN');
    }

    public function testEqualityByValue(): void
    {
        $a = new Price(amountInCents: 1999, currency: 'PLN');
        $b = new Price(amountInCents: 1999, currency: 'PLN');
        $this->assertTrue($a->equals($b));
    }

    public function testInequalityOnDifferentCurrency(): void
    {
        $a = new Price(amountInCents: 1999, currency: 'PLN');
        $b = new Price(amountInCents: 1999, currency: 'EUR');
        $this->assertFalse($a->equals($b));
    }
}
```

### What to Test in Domain Layer

- Value Object validation (constructor rejects invalid data)
- Value Object equality (`equals()` method)
- Entity state changes and invariant enforcement
- Domain event recording on Aggregate Roots
- Enum cases and transitions

## What to Test in Headless WP

### Must test
- **GraphQL field registrations** — fields are registered with correct types and resolvers
- **GraphQL resolvers** — return expected data, handle missing data, sanitize output
- **WC filter callbacks** — Store API schema extensions, REST response modifications
- **mu-plugin hook registration** — correct hooks, correct priorities
- **Input sanitization** — all user input is sanitized before use
- **Capability checks** — privileged operations require correct capabilities

### Don't test (framework responsibility)
- WordPress core functions (they work)
- WooCommerce internal logic
- GraphQL query parsing (WPGraphQL handles this)
- Composer autoloading

## Definition of Done Checklist

- [ ] All new mu-plugin functions have corresponding tests
- [ ] All GraphQL field registrations are tested
- [ ] All WC filter callbacks are tested with edge cases
- [ ] Tests pass: `docker compose run --rm wpcli bash -c "cd /var/www/html && php vendor/bin/phpunit"`
- [ ] No `@codeCoverageIgnore` without documented reason
- [ ] Test names describe behavior: `testResolverReturnsNullWhenMetaKeyMissing`
