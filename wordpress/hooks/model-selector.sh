#!/usr/bin/env bash
# model-selector.sh — UserPromptSubmit hook
# Injects model selection criteria before each prompt so the model
# declares which tier (opus/sonnet/haiku) to use before executing.

cat <<'EOF'
=== MODEL SELECTION REQUIRED ===
Before taking any action, assess the task complexity and declare:

  OPUS   → ddd-modeler, wp-architecture-planner, complex security audits on critical
            auth/payment code, multi-plugin architecture decisions
  SONNET → wp-api-developer, woo-configurator, wp-php-reviewer, wp-diagnostician,
            Docker/nginx changes, standard PHP implementation, any significant code
  HAIKU  → log analysis, WP-CLI one-liners, Composer dependency lookups,
            simple config edits, lint/PHPStan runs

When spawning agents via the Agent tool, set the `model` parameter accordingly.
State your choice (one line) at the start of your response, e.g.:
  "Model: opus — modelowanie domeny zamówień (DDD)"
================================
EOF
