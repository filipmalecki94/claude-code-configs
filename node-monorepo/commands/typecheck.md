Run TypeScript type checking for the specified package.

Argument: "$ARGUMENTS" (server | web | empty = both)

If "$ARGUMENTS" is "server" or empty:
  Run: npx tsc --noEmit --project packages/server/tsconfig.json

If "$ARGUMENTS" is "web" or empty:
  Run: npx tsc --noEmit --project packages/web/tsconfig.app.json

Report all errors with file path, line number, and suggested fix.
