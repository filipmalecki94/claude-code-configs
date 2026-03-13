#!/usr/bin/env bash
# model-selector.sh — UserPromptSubmit hook
# Injects model selection criteria before each prompt so the model
# declares which tier (opus/sonnet/haiku) to use before executing.
#
# FORCE SYNTAX: Start your prompt with one of:
#   !opus   — force Opus regardless of task complexity
#   !sonnet — force Sonnet
#   !haiku  — force Haiku

# Read JSON input from stdin
INPUT="$(cat)"
PROMPT="$(echo "$INPUT" | grep -o '"prompt":"[^"]*"' | sed 's/"prompt":"//;s/"$//' 2>/dev/null || true)"

# Check for force prefix (case-insensitive)
FORCED_MODEL=""
case "$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//' | cut -c1-8)" in
  "!opus"*)   FORCED_MODEL="OPUS" ;;
  "!sonnet"*) FORCED_MODEL="SONNET" ;;
  "!haiku"*)  FORCED_MODEL="HAIKU" ;;
esac

if [ -n "$FORCED_MODEL" ]; then
  cat <<EOF
=== MODEL OVERRIDE ACTIVE ===
Model has been FORCED to: $FORCED_MODEL
Skip model selection — use $FORCED_MODEL for this task and all agents spawned.
==============================
EOF
else
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

TIP: Start your prompt with !opus / !sonnet / !haiku to force a specific model.
================================
EOF
fi
