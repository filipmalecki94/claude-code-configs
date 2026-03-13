#!/usr/bin/env bash
# model-selector.sh — UserPromptSubmit hook
# Injects model selection criteria before each prompt so the model
# declares which tier (opus/sonnet/haiku) to use before executing.

cat <<'EOF'
=== MODEL SELECTION REQUIRED ===
Before taking any action, assess the task complexity and declare:

  OPUS   → complex multi-page architecture planning, deep security audits on Stripe/auth
            flows, ISR + GraphQL data strategy design requiring multi-system analysis
  SONNET → react-component-builder, store-api-checkout, wpgraphql-data,
            nextjs-code-reviewer, nextjs-test-writer, standard component/API route
            implementation, any task that involves writing significant code
  HAIKU  → log/output analysis, TypeScript type lookups, single-file lint fixes,
            quick GraphQL schema checks, status reads

When spawning agents via the Agent tool, set the `model` parameter accordingly.
State your choice (one line) at the start of your response, e.g.:
  "Model: sonnet — budowanie komponentu Cart"
================================
EOF
