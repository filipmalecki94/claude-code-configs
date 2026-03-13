---
description: Run PHPUnit tests — full suite, single file, or filtered
argument: Optional path to test file or --filter pattern
---

Run PHPUnit tests for the WordPress headless backend.

## Usage

- No argument: run full test suite
- File path: run single test file (e.g., `tests/Unit/MuPlugin/GraphqlExtensionsTest.php`)
- `--filter <method>`: run specific test method

## Commands

```bash
# Full suite
cd /home/fifi/Documents/Projects/missio/missio-docker && docker compose run --rm wpcli bash -c "cd /var/www/html && php vendor/bin/phpunit"

# Single file (replace path)
cd /home/fifi/Documents/Projects/missio/missio-docker && docker compose run --rm wpcli bash -c "cd /var/www/html && php vendor/bin/phpunit $ARGUMENTS"

# With coverage
cd /home/fifi/Documents/Projects/missio/missio-docker && docker compose run --rm wpcli bash -c "cd /var/www/html && php vendor/bin/phpunit --coverage-text"
```

## Behavior

1. If `$ARGUMENTS` is empty — run full suite
2. If `$ARGUMENTS` is a file path — run that file
3. If `$ARGUMENTS` starts with `--filter` — pass as PHPUnit filter
4. Report results: passed, failed, errors, skipped
5. On failure: show the failing test name, expected vs actual, and suggest fix
