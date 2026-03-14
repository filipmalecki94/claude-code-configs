Utwórz nową stronę App Router w projekcie Next.js.

## Argumenty

$ARGUMENTS — ścieżka strony w formacie App Router, np.:
- `(shop)/products/[slug]` — dynamiczna strona produktu
- `blog` — statyczna strona listy
- `account/settings` — zagnieżdżona strona
- `(shop)/categories/[slug]/[page]` — strona z wieloma parametrami

## Co wygenerować

Utwórz **3 pliki** w `src/app/<ścieżka>/`:

### 1. `page.tsx`

```tsx
// Wzorzec dla strony BEZ dynamicznych parametrów:
export default function NazwaPage() {
  return (
    <main>
      <h1>Tytuł strony</h1>
    </main>
  );
}

// Wzorzec dla strony Z dynamicznymi parametrami (Next.js 15 async params):
export default async function NazwaPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  return (
    <main>
      <h1>Tytuł: {slug}</h1>
    </main>
  );
}
```

### 2. `loading.tsx`

```tsx
export default function Loading() {
  return (
    <main className="flex min-h-[50vh] items-center justify-center">
      <div className="animate-pulse text-lg text-gray-500">Ładowanie...</div>
    </main>
  );
}
```

### 3. `error.tsx`

```tsx
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <main className="flex min-h-[50vh] flex-col items-center justify-center gap-4">
      <h2 className="text-xl font-semibold">Coś poszło nie tak</h2>
      <button
        onClick={reset}
        className="rounded bg-black px-4 py-2 text-white hover:bg-gray-800"
      >
        Spróbuj ponownie
      </button>
    </main>
  );
}
```

## Zasady

1. **Async params** — Next.js 15 wymaga `params: Promise<{ ... }>` z `await params` dla dynamicznych segmentów (`[slug]`, `[id]` itp.)
2. **Server Component** domyślnie — nie dodawaj `'use client'` chyba że strona wymaga interaktywności (error.tsx jest wyjątkiem)
3. **Tailwind CSS** — używaj klas Tailwind, nie CSS modules
4. **Polski UI** — teksty użytkownika po polsku (nagłówki, przyciski, komunikaty)
5. **Istniejące wzorce** — sprawdź istniejące strony w `src/app/` i zachowaj spójność konwencji
6. **Route groups** — jeśli ścieżka zaczyna się od `(shop)`, `(auth)` itp., to jest route group i nie wpływa na URL
7. **Metadata** — jeśli strona ma publiczny tytuł, dodaj eksport `metadata` lub `generateMetadata`:
   ```tsx
   export const metadata = { title: 'Tytuł strony — App' };
   ```
8. **Nie nadpisuj** istniejących plików — sprawdź czy strona już istnieje przed utworzeniem

Po utworzeniu plików potwierdź co zostało wygenerowane i jaką ścieżką URL strona będzie dostępna.

## Po utworzeniu — agenci
Rozważ uruchomienie agenta **nextjs-test-writer** dla testów i **nextjs-code-reviewer** do przeglądu.
