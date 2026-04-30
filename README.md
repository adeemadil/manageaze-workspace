# ManagEaze Workspace

Coordination repo for docs, planning, and multi-repo orchestration.

## Linked Repositories

- app-backend-manageaze
- app-frontend-manageaze
- manageaze-prototype

## Quick Start

Clone with submodules:
`git clone --recurse-submodules git@github.com:adeemadilkhatri/manageaze-workspace.git`

Update all linked repos:
`git submodule update --remote --merge`

## Team-Safe Daily Sync

Run this before starting work:
`./scripts/reconcile.sh`

What it does:

- Ensures umbrella + submodules are clean (fails fast if someone forgot to commit/stash)
- Pulls umbrella with `--ff-only`
- Syncs and updates all submodules to remote `main`
- Prints resulting submodule SHAs

If you intentionally want to continue with local changes:
`./scripts/reconcile.sh --allow-dirty`

If you already pulled umbrella and only want submodules:
`./scripts/reconcile.sh --skip-umbrella-pull`

## One-Shot Workspace Health Check

Run this anytime to see umbrella + each submodule status:
`./scripts/status-all.sh`

It prints:

- branch + short commit for umbrella and each submodule
- upstream tracking + ahead/behind counts
- dirty files (if any)
- current submodule pointer SHAs

