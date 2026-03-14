# pixel-agents-web

Standalone web port of [pixel-agents](https://github.com/pablodelucca/pixel-agents)
VS Code extension by Pablo De Lucca (MIT). Replaces VS Code Webview API with
Express + WebSocket, enabling `npx pixel-agents-web --path .` without VS Code.

## Common commands

```bash
npm run dev              # dev:server + dev:web concurrently
npm run dev:server       # tsx watch packages/server/src/cli.ts
npm run dev:web          # vite dev server (packages/web)
npm run build            # packages/web (Vite) then packages/server (tsc)
npm -w packages/server run build   # typecheck + compile server only
npm -w packages/web run build      # vite build web only
```

## Architecture

npm workspaces monorepo. Two packages:

**packages/server** — Node.js ESM, TypeScript strict
- `src/cli.ts` — yargs CLI entry point (`npx pixel-agents-web`)
- `src/server.ts` — Express 5 + WebSocketServer setup
- `src/agentServer.ts` — main class; implements MessageSink; broadcasts to all WS clients
- `src/fileWatcher.ts` — chokidar watching `~/.claude/projects/<dir>/*.jsonl`
- `src/transcriptParser.ts` — incremental JSONL parsing (offset-based)
- `src/layoutPersistence.ts` — reads/writes `~/.pixel-agents/settings.json`
- `src/messageSink.ts` — interface replacing `vscode.Webview`

**packages/web** — React 19, Vite, TypeScript strict
- `src/vscodeApi.ts` — WebSocket bridge replacing `acquireVsCodeApi()`
- `src/App.tsx` — root component; terminal actions removed (no VS Code)
- `src/hooks/useExtensionMessages.ts` — unchanged from original; listens `window 'message'`
- WebSocket bridge emits `window.dispatchEvent(new MessageEvent(...))` to stay compatible

## Key constraints

- All files are ESM (`"type": "module"`, `.js` extensions in imports)
- TypeScript strict mode in both packages — no `any`, no `as` casts without comment
- `packages/web/src/hooks/useExtensionMessages.ts` — copy verbatim from original, do NOT modify
- Server never imports from `vscode` — use `MessageSink` interface instead
- Assets (PNG sprites) are loaded server-side via pngjs and sent over WebSocket

## Active implementation plan

See `PLAN.md` — 4 stages: Setup → Frontend → Server → CLI+npm
