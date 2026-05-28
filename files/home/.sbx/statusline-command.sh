#!/usr/bin/env bash

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown model"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$used" ]; then
  filled=$(printf "%.0f" "$(echo "$used * 10 / 100" | bc -l)")
  empty=$((10 - filled))
  bar=""
  for i in $(seq 1 "$filled"); do bar="${bar}█"; done
  for i in $(seq 1 "$empty"); do bar="${bar}░"; done
  pct=$(printf "%.0f" "$used")
  printf "%s | [%s] %s%%" "$model" "$bar" "$pct"
else
  printf "%s | [░░░░░░░░░░] -" "$model"
fi
