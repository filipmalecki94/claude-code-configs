# AGENT-PROMPTS.md

Instrukcje do tworzenia i modyfikowania agentów Claude Code w projekcie missio.

---

## DDD Modeler Agent

### Opis

Agent `ddd-modeler` odpowiada za Domain-Driven Design w projekcie missio. Działa w trybie hybrydowym:
- **Strategic DDD** — Bounded Contexts, Context Maps, Ubiquitous Language
- **Tactical DDD** — szkielety klas PHP 8.4 (Value Objects, Entities, Aggregates, Repositories, Domain Services, Domain Events)
- **NIE implementuje** pełnej logiki biznesowej — deleguje do `wp-api-developer`

### Jak dodać agenta

1. Utwórz plik `.claude/agents/ddd-modeler.md` z pełnym promptem (frontmatter YAML + treść)
2. Dodaj agenta do tabeli w `CLAUDE.md` sekcja "Agent Delegation"
3. Agent jest automatycznie dostępny przez `subagent_type: "ddd-modeler"` w narzędziu Agent

### Kiedy używać

- Modelowanie nowej domeny biznesowej (np. "zamodeluj domenę Catalog")
- Definiowanie Bounded Contexts i ich granic
- Generowanie szkieletów klas DDD w PHP 8.4
- Tworzenie Domain Events dla procesów biznesowych
- Projektowanie Value Objects (Money, Address, SKU, Email)
- Analiza integracji między kontekstami (Context Map)

### Kluczowe zasady prompta

1. **Namespace**: `Missio\Domain\{Context}` (np. `Missio\Domain\Catalog`)
2. **Katalog**: `web/app/mu-plugins/missio-domain/{Context}/`
3. **PHP 8.4**: readonly classes, enums, typed properties, constructor promotion
4. **PSR-12**: strict types, final readonly VOs, interfejsy repozytoriów
5. **Framework-agnostic domain**: brak importów WooCommerce w klasach domenowych
6. **Szkielety z TODO**: metody zawierają `// TODO:` dla `wp-api-developer`

### Prompt agenta

Pełna treść prompta znajduje się w: `.claude/agents/ddd-modeler.md`

Frontmatter:
```yaml
---
name: ddd-modeler
description: "Use this agent when you need to model e-commerce business domains using Domain-Driven Design..."
model: sonnet
---
```

### Przykładowe użycie

```
User: "Zamodeluj domenę Catalog z produktami i wariantami"

→ Agent analizuje istniejące mu-plugins
→ Definiuje Bounded Context "Catalog"
→ Tworzy Ubiquitous Language (Product, Variant, Price, SKU, Category)
→ Generuje szkielety: Product (Aggregate Root), ProductVariant (Entity),
  Price/Sku (Value Objects), ProductRepositoryInterface, ProductCreated event
→ Wskazuje integration points z WPGraphQL i Store API
→ Deleguje implementację do wp-api-developer
```

### Powiązani agenci

| Kolejność | Agent | Rola |
|-----------|-------|------|
| 1 | `ddd-modeler` | Modelowanie domeny, szkielety klas |
| 2 | `wp-architecture-planner` | Plan implementacji integracji z WooCommerce |
| 3 | `php-unit-tester` | Testy jednostkowe dla domain logic |
| 4 | `wp-api-developer` | Implementacja pełnej logiki, repozytoria, API |
| 5 | `wp-php-reviewer` | Code review |
| 6 | `wp-security-auditor` | Audyt bezpieczeństwa |
