#!/usr/bin/env bash
set -euo pipefail

# Team-safe reconcile script for umbrella + submodules.
# Default behavior is intentionally strict:
# - Fails if umbrella repo has unstaged/uncommitted changes
# - Fails if any submodule has unstaged/uncommitted changes
# - Fast-forwards umbrella and each submodule to latest remote main

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ALLOW_DIRTY=0
SKIP_UMBRELLA_PULL=0

for arg in "$@"; do
  case "$arg" in
    --allow-dirty)
      ALLOW_DIRTY=1
      ;;
    --skip-umbrella-pull)
      SKIP_UMBRELLA_PULL=1
      ;;
    -h|--help)
      cat <<'EOF'
Usage: ./scripts/reconcile.sh [options]

Options:
  --allow-dirty         Continue even if repos have local changes
  --skip-umbrella-pull  Do not pull umbrella repo before syncing submodules
  -h, --help            Show this help
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg"
      echo "Run with --help for usage."
      exit 1
      ;;
  esac
done

cd "$ROOT_DIR"

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd"
    exit 1
  fi
}

require_cmd git

if [[ ! -f ".gitmodules" ]]; then
  echo "No .gitmodules found. Run this from the ManagEaze umbrella repo."
  exit 1
fi

check_repo_clean() {
  local repo_path="$1"
  local label="$2"
  local out
  out="$(git -C "$repo_path" status --porcelain)"
  if [[ -n "$out" ]]; then
    echo "Dirty repo detected: $label"
    echo "$out"
    return 1
  fi
  return 0
}

if [[ "$ALLOW_DIRTY" -ne 1 ]]; then
  echo "Preflight: checking for local changes..."
  check_repo_clean "." "umbrella" || {
    echo
    echo "Aborting. Commit/stash/reset umbrella changes first,"
    echo "or rerun with --allow-dirty."
    exit 1
  }

  while IFS= read -r sub_path; do
    check_repo_clean "$sub_path" "$sub_path" || {
      echo
      echo "Aborting. Commit/stash/reset submodule changes first,"
      echo "or rerun with --allow-dirty."
      exit 1
    }
  done < <(git config --file .gitmodules --get-regexp path | awk '{print $2}')
fi

echo "Syncing submodule URLs..."
git submodule sync --recursive

if [[ "$SKIP_UMBRELLA_PULL" -ne 1 ]]; then
  echo "Pulling umbrella repo..."
  git pull --ff-only
fi

echo "Updating submodule pointers from remote..."
git submodule update --init --remote --merge

echo
echo "Submodule status:"
git submodule status

echo
echo "Reconcile complete."
echo "If submodule pointers changed, commit them in umbrella:"
echo "  git add .gitmodules app-backend-manageaze app-frontend-manageaze manageaze-prototype"
echo "  git commit -m \"chore: reconcile submodule pointers\""
