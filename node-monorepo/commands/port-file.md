Port the file `$ARGUMENTS` from the original pixel-agents VS Code extension
(pablodelucca/pixel-agents) to this project.

1. Use GitHub MCP to read `$ARGUMENTS` from repo `pablodelucca/pixel-agents`, branch `main`
2. Determine destination:
   - `src/*.ts` → `packages/server/src/`
   - `webview-ui/src/*.ts` or `webview-ui/src/*.tsx` → `packages/web/src/`
3. Apply the migration table from `.claude/agents/port-migration.md`
4. Write the file with minimal changes only — do NOT refactor unrelated code
5. Run: `npx tsc --noEmit --project packages/<server|web>/tsconfig.json`
6. Report: list every change made and why
