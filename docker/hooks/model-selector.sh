#!/usr/bin/env bash
# model-selector.sh — UserPromptSubmit hook
# Injects model selection criteria before each prompt so the model
# declares which tier (opus/sonnet/haiku) to use before executing.

cat <<'EOF'
=== MODEL SELECTION REQUIRED ===
Before taking any action, assess the task complexity and declare:

  OPUS   → complex planning, architecture design, DDD modeling, multi-system analysis,
            security audits requiring deep cross-system reasoning, tasks using the
            "Plan" agent or ddd-modeler/wp-architecture-planner agents
  SONNET → standard implementation (API endpoints, components, Dockerfiles, nginx),
            code review, debugging, docker-infra changes, checkout/payment flows,
            any task that involves writing significant code
  HAIKU  → log analysis (/dc-logs), status checks (/dc-status), simple config edits,
            lint/format runs, single-file searches, quick lookups

When spawning agents via the Agent tool, set the `model` parameter accordingly.
State your choice (one line) at the start of your response, e.g.:
  "Model: sonnet — implementacja endpointu REST"
================================
EOF
