Generate a Vitest test file for `$ARGUMENTS`.

Rules:
- Destination: same directory as source, `.test.ts` suffix
- Mock `MessageSink` as a plain object: `{ postMessage: vi.fn() }`
- For filesystem tests: use real temp dir via `fs.mkdtempSync`, never mock fs
- For WebSocket tests: use a real `ws` server on a random port (port: 0), never mock ws
- Test happy path + key edge cases from PLAN.md section 3.4

After writing, run: npx tsc --noEmit to verify types compile.
