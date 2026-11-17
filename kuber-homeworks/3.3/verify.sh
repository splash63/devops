#!/usr/bin/env bash
set -euo pipefail
mode="${1:-after}"
[[ "$mode" == before || "$mode" == after ]] || { echo 'Usage: bash verify.sh [before|after]'; exit 2; }
failed=0
for src in frontend backend cache; do
  for dst in frontend backend cache; do
    [[ "$src" != "$dst" ]] || continue
    ip=$(kubectl -n app get "svc/$dst" -o jsonpath='{.spec.clusterIP}')
    expected=28
    if [[ "$mode" == before || "$src/$dst" == frontend/backend || "$src/$dst" == backend/cache ]]; then
      expected=0
    fi
    printf '\n=== %s -> %s (%s): expected exit %s ===\n' "$src" "$dst" "$ip" "$expected"
    rc=0
    kubectl -n app exec "deploy/$src" -- curl --noproxy '*' -fsS --connect-timeout 3 --max-time 5 "http://$ip/" || rc=$?
    if [[ "$rc" == "$expected" ]]; then
      printf '\nPASS (exit %s)\n' "$rc"
    else
      printf '\nFAIL (exit %s)\n' "$rc"
      failed=1
    fi
  done
done
exit "$failed"
