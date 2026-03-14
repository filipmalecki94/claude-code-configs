---
description: Model e-commerce domain with DDD — Bounded Contexts, Aggregates, PHP 8.4 class skeletons
argument: Domain or subdomain to model (e.g. "Catalog", "Order z fulfillment", "Payment z refundami")
---

Perform Domain-Driven Design modeling for the headless WooCommerce backend.

## Behavior

1. **Determine scope:**
   - If `$ARGUMENTS` specifies a domain/subdomain — model that context
   - If empty — analyze all 7 e-commerce domains (Catalog, Cart, Order, Payment, Shipping, Customer, Inventory) and produce a high-level Context Map

2. **Use the `ddd-modeler` agent** to perform the analysis and generate outputs.

3. **Expected outputs:**

   **Strategic DDD:**
   - Bounded Context definitions and responsibilities
   - Context Map (relationships between contexts)
   - Ubiquitous Language glossary

   **Tactical DDD:**
   - Aggregate design (root entity, child entities, value objects, invariants)
   - Domain Event definitions
   - PHP 8.4 class skeletons in `web/app/mu-plugins/{project}-domain/src/{Context}/`
   - Repository interfaces

4. **Class skeletons** follow these conventions:
   - Namespace: `App\Domain\{Context}`
   - Value Objects: `final readonly class`, self-validating
   - Entities: typed properties, domain event recording
   - Repository interfaces only (implementations delegated to `wp-api-developer`)
   - `// TODO:` markers for business logic

5. **After modeling**, suggest next steps:
   - `wp-architecture-planner` — plan WooCommerce integration layer
   - `/test` — write unit tests for domain classes (pure PHPUnit, no Brain Monkey needed)
   - `wp-api-developer` — implement `// TODO:` method bodies and repository implementations
