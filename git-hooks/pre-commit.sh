#!/usr/bin/env bash
set -euo pipefail

# Ensure the code is formatted
mix format --check-formatted

# Really ensure the code is formatted
mix credo --strict
