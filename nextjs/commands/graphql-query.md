Utwórz typowany query GraphQL dla WPGraphQL w projekcie Next.js.

## Argumenty

$ARGUMENTS — opis danych do pobrania, np.:
- `lista produktów z kategorią i ceną`
- `pojedynczy post po slug z autorem i tagami`
- `kategorie produktów z liczbą produktów`
- `produkty z paginacją cursor-based`

## Co wygenerować

### 1. Query GraphQL + typy TypeScript w jednym pliku

Utwórz plik w `src/lib/api/queries/` (np. `products.ts`, `posts.ts`, `categories.ts`):

```tsx
import { fetchGraphQL } from '@/lib/api/graphql';

// --- GraphQL Query ---

const GET_PRODUCTS = `
  query GetProducts($first: Int!, $after: String) {
    products(first: $first, after: $after) {
      pageInfo {
        hasNextPage
        endCursor
      }
      nodes {
        id
        databaseId
        name
        slug
        ... on SimpleProduct {
          price
          regularPrice
          salePrice
        }
        image {
          sourceUrl
          altText
        }
        productCategories {
          nodes {
            id
            name
            slug
          }
        }
      }
    }
  }
`;

// --- Response Types ---

interface GetProductsResponse {
  products: {
    pageInfo: PageInfo;
    nodes: ProductNode[];
  };
}

interface PageInfo {
  hasNextPage: boolean;
  endCursor: string | null;
}

interface ProductNode {
  id: string;
  databaseId: number;
  name: string;
  slug: string;
  price: string;
  regularPrice: string;
  salePrice: string | null;
  image: { sourceUrl: string; altText: string } | null;
  productCategories: {
    nodes: { id: string; name: string; slug: string }[];
  };
}

// --- Fetcher Function ---

export async function getProducts(first = 12, after?: string) {
  const data = await fetchGraphQL<GetProductsResponse>(GET_PRODUCTS, { first, after });
  return data.products;
}
```

### 2. Eksport typów do `src/types/` (jeśli typy będą reużywane)

Dodaj lub zaktualizuj odpowiedni plik w `src/types/` jeśli typy mogą być potrzebne w wielu miejscach.

## Zasady — WPGraphQL + WooCommerce

1. **Connection pattern** — WPGraphQL używa wzorca connections:
   - Listy: `products(first: $first, after: $after) { pageInfo { hasNextPage, endCursor } nodes { ... } }`
   - Relacje: `productCategories { nodes { id, name, slug } }`
   - Nigdy nie zwraca zwykłych tablic — zawsze `{ nodes: [...] }`

2. **Paginacja cursor-based** — używaj `first`/`after` (forward) lub `last`/`before` (backward):
   ```graphql
   query($first: Int!, $after: String) {
     products(first: $first, after: $after) {
       pageInfo { hasNextPage, endCursor }
       nodes { ... }
     }
   }
   ```

3. **WooCommerce product types** — produkty mogą być różnych typów, użyj inline fragments:
   ```graphql
   ... on SimpleProduct { price, regularPrice, salePrice }
   ... on VariableProduct { price, variations { nodes { ... } } }
   ```

4. **Pola WPGraphQL for WooCommerce** (najczęściej używane):
   - Produkty: `id, databaseId, name, slug, description, shortDescription, price, regularPrice, salePrice, onSale, image, galleryImages, productCategories, attributes`
   - Posty: `id, databaseId, title, slug, content, excerpt, date, author { node { name } }, categories { nodes { name, slug } }, tags { nodes { name } }, featuredImage { node { sourceUrl, altText } }`
   - Kategorie produktów: `id, name, slug, description, count, image { sourceUrl }`

5. **Fetcher** — zawsze używaj `fetchGraphQL<T>()` z `@/lib/api/graphql`:
   ```tsx
   const data = await fetchGraphQL<ResponseType>(QUERY, variables);
   ```

6. **ISR** — w komponentach stron dodaj revalidation:
   ```tsx
   // W page.tsx:
   export const revalidate = 60; // ISR co 60 sekund
   ```

7. **TypeScript** — typuj response od GraphQL, nie używaj `any`

8. **Nazewnictwo** — queries: `GET_PRODUCTS`, `GET_PRODUCT_BY_SLUG`; funkcje: `getProducts()`, `getProductBySlug()`

Po utworzeniu pliku potwierdź query, pokaż jak użyć fetcher function w page.tsx i przypomnij o `revalidate`.

## Po utworzeniu — agenci
Rozważ uruchomienie agenta **nextjs-test-writer** aby napisać testy dla fetcher function.
