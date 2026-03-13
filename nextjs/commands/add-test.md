Dodaj testy dla istniejącego pliku w projekcie Next.js.

## Argumenty

$ARGUMENTS — ścieżka do pliku lub opis co przetestować, np.:
- `src/components/product/ProductCard.tsx` — testy komponentu
- `src/lib/api/queries/products.ts` — testy fetcher function
- `checkout flow e2e` — test E2E procesu checkout
- `src/app/cart/page.tsx` — testy strony

## Strategia doboru typu testów

Na podstawie pliku/opisu zdecyduj jaki typ testów utworzyć:

### A. Komponent React → Jest + React Testing Library

Plik: `<katalog>/__tests__/<NazwaKomponentu>.test.tsx`

```tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { NazwaKomponentu } from '../NazwaKomponentu';

describe('NazwaKomponentu', () => {
  it('renderuje się poprawnie', () => {
    render(<NazwaKomponentu />);
    expect(screen.getByRole('heading')).toHaveTextContent('Oczekiwany tekst');
  });

  it('obsługuje interakcję', async () => {
    const user = userEvent.setup();
    render(<NazwaKomponentu onAction={mockFn} />);
    await user.click(screen.getByRole('button', { name: /dodaj/i }));
    expect(mockFn).toHaveBeenCalledOnce();
  });
});
```

### B. Moduł API / fetcher → Jest + MSW v2

Plik: `<katalog>/__tests__/<modul>.test.ts`

```tsx
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import { getProducts } from '../queries/products';

const server = setupServer(
  http.post('*/graphql', () => {
    return HttpResponse.json({
      data: {
        products: {
          pageInfo: { hasNextPage: false, endCursor: null },
          nodes: [{ id: '1', name: 'Test Product', slug: 'test-product' }],
        },
      },
    });
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('getProducts', () => {
  it('zwraca listę produktów', async () => {
    const result = await getProducts(10);
    expect(result.nodes).toHaveLength(1);
    expect(result.nodes[0].name).toBe('Test Product');
  });

  it('obsługuje błąd API', async () => {
    server.use(
      http.post('*/graphql', () => {
        return new HttpResponse(null, { status: 500 });
      })
    );
    await expect(getProducts(10)).rejects.toThrow();
  });
});
```

### C. Flow użytkownika → Cypress E2E

Plik: `cypress/e2e/<flow>.cy.ts`

```tsx
describe('Checkout Flow', () => {
  beforeEach(() => {
    cy.visit('/');
  });

  it('pozwala gościowi przejść przez checkout', () => {
    cy.get('[data-testid="product-card"]').first().click();
    cy.get('[data-testid="add-to-cart"]').click();
    cy.visit('/cart');
    cy.get('[data-testid="checkout-button"]').click();
    // ... dalsze kroki
  });
});
```

## Zasady

1. **Przeczytaj plik źródłowy** — zanim napiszesz testy, przeczytaj testowany plik aby zrozumieć:
   - Jakie props/parametry przyjmuje
   - Co renderuje / zwraca
   - Jakie ma side effects (API calls, state changes)
   - Jakie edge cases mogą wystąpić

2. **Testing Library best practices**:
   - Szukaj po roli, tekście, labelu — nie po selektorach CSS
   - `getByRole('button', { name: /dodaj/i })` > `getByTestId('add-btn')`
   - `userEvent` > `fireEvent` dla interakcji użytkownika
   - `waitFor` dla asynchronicznych zmian DOM

3. **MSW v2 syntax** — używaj nowego API:
   - `http.get()`, `http.post()` zamiast `rest.get()`
   - `HttpResponse.json()` zamiast `res(ctx.json())`
   - `setupServer()` z `msw/node`

4. **Polski tekst w assertions** — jeśli UI jest po polsku, assertions też:
   ```tsx
   expect(screen.getByText('Dodaj do koszyka')).toBeInTheDocument();
   ```

5. **Co testować** (priorytet):
   - Renderowanie z różnymi props (happy path)
   - Interakcje użytkownika (kliknięcia, formularze)
   - Stany brzegowe (pusta lista, błąd, loading)
   - Warunkowe renderowanie (sale price, out of stock)

6. **Czego NIE testować**:
   - Szczegółów implementacji (state wewnętrzny)
   - Styli CSS / klas Tailwind
   - Third-party library internals

7. **Konwencja plików**:
   - Unit/component: `__tests__/<Nazwa>.test.tsx` obok testowanego pliku
   - E2E: `cypress/e2e/<flow>.cy.ts`

Po utworzeniu testów uruchom je (`npm run test:ci -- --testPathPattern=<plik>` lub `npm run cypress:run`) i potwierdź wynik.

## Po utworzeniu — agenci
Jeśli testy dotyczą kodu z płatnościami lub autentykacją, rozważ uruchomienie agenta **security-auditor**.
