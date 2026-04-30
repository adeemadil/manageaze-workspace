#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f ".gitmodules" ]]; then
  echo "No .gitmodules found. Run this from the ManagEaze umbrella repo."
  exit 1
fi

section() {
  printf "\n===== %s =====\n" "$1"
}

print_repo_status() {
  local repo_path="$1"
  local label="$2"

  echo "$label"
  echo "  path: $repo_path"
  echo "  branch: $(git -C "$repo_path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
  echo "  commit: $(git -C "$repo_path" rev-parse --short HEAD 2>/dev/null || echo n/a)"

  local upstream
  upstream="$(git -C "$repo_path" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true)"
  if [[ -n "$upstream" ]]; then
    echo "  upstream: $upstream"
    local ahead behind
    ahead="$(git -C "$repo_path" rev-list --count @{u}..HEAD 2>/dev/null || echo 0)"
    behind="$(git -C "$repo_path" rev-list --count HEAD..@{u} 2>/dev/null || echo 0)"
    echo "  ahead/behind: +$ahead/-$behind"
  else
    echo "  upstream: (none)"
  fi

  local dirty
  dirty="$(git -C "$repo_path" status --porcelain)"
  if [[ -n "$dirty" ]]; then
    echo "  dirty: yes"
    echo "$dirty" | sed 's/^/    /'
  else
    echo "  dirty: no"
  fi
}

section "Umbrella"
print_repo_status "." "umbrella"

section "Submodules"
while IFS= read -r sub_path; do
  print_repo_status "$sub_path" "$sub_path"
done < <(git config --file .gitmodules --get-regexp path | awk '{print $2}')

section "Pointers"
git submodule status

echo
echo "Tip: run ./scripts/reconcile.sh before starting focused work."
