Utwórz nowy komponent React w projekcie Next.js.

## Argumenty

$ARGUMENTS — ścieżka komponentu w formacie `katalog/NazwaKomponentu`, np.:
- `ui/Button` — komponent UI w `src/components/ui/`
- `product/ProductCard` — komponent produktu w `src/components/product/`
- `cart/CartItem` — komponent koszyka w `src/components/cart/`
- `layout/Header` — komponent layoutu w `src/components/layout/`

## Co wygenerować

### 1. Plik komponentu: `src/components/<katalog>/<NazwaKomponentu>.tsx`

```tsx
// Server Component (domyślnie):
interface NazwaKomponentuProps {
  // props
}

export function NazwaKomponentu({ ...props }: NazwaKomponentuProps) {
  return (
    <div>
      {/* implementacja */}
    </div>
  );
}

// Client Component (tylko gdy wymaga useState, useEffect, onClick itp.):
'use client';

import { useState } from 'react';

interface NazwaKomponentuProps {
  // props
}

export function NazwaKomponentu({ ...props }: NazwaKomponentuProps) {
  return (
    <div>
      {/* implementacja */}
    </div>
  );
}
```

### 2. Plik testowy: `src/components/<katalog>/__tests__/<NazwaKomponentu>.test.tsx`

```tsx
import { render, screen } from '@testing-library/react';
import { NazwaKomponentu } from '../NazwaKomponentu';

describe('NazwaKomponentu', () => {
  it('renderuje się poprawnie', () => {
    render(<NazwaKomponentu />);
    // assertions
  });
});
```

## Zasady

1. **Server Component domyślnie** — dodawaj `'use client'` TYLKO gdy komponent wymaga:
   - React hooks (useState, useEffect, useRef, useContext)
   - Event handlers (onClick, onChange, onSubmit)
   - Browser APIs (window, document, localStorage)
2. **Named export** — używaj `export function`, nie `export default`
3. **Interfejs props** — zawsze definiuj `interface NazwaProps` nawet gdy props są proste
4. **Tailwind CSS** — stylowanie wyłącznie przez klasy Tailwind
5. **Import alias** — używaj `@/` zamiast ścieżek relatywnych (`import { Button } from '@/components/ui/Button'`)
6. **Katalogi komponentów**:
   - `ui/` — bazowe komponenty UI (Button, Input, Modal, Badge)
   - `product/` — komponenty związane z produktami
   - `cart/` — komponenty koszyka
   - `layout/` — nagłówek, stopka, nawigacja, sidebar
7. **Dostępność (a11y)** — semantic HTML, aria-labels gdzie potrzebne, poprawna hierarchia nagłówków
8. **Polski UI** — teksty widoczne dla użytkownika po polsku
9. **Nie nadpisuj** istniejących plików — sprawdź czy komponent już istnieje

Po utworzeniu plików potwierdź co zostało wygenerowane i pokaż przykład importu komponentu.

## Po utworzeniu — agenci
Rozważ uruchomienie agenta **nextjs-test-writer** aby rozszerzyć testy, a potem **nextjs-code-reviewer** do przeglądu.
