#!/usr/bin/env bash
# Pull the latest repo, then refresh the global install and every initialized project.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  cat <<EOF
Usage: ultimate-skills update [--no-pull]

1. git pull --ff-only in this repo (skip with --no-pull)
2. Re-run 'ultimate-skills install' if the global install is present
3. Re-run 'ultimate-skills init' for every project in $REGISTRY,
   keeping each project's selectors; projects that no longer exist are dropped

Options:
  --no-pull   Don't pull; just re-sync from the current checkout
EOF
}

pull=1
for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    --no-pull) pull=0 ;;
    *) die "Unknown option: $arg" ;;
  esac
done

scripts="$REPO_ROOT/scripts"

if [ "$pull" -eq 1 ]; then
  git -C "$REPO_ROOT" pull --ff-only || die "git pull failed; resolve it or re-run with --no-pull"
fi

if is_our_link "$HOME/.claude/rules/$NAMESPACE"; then
  bash "$scripts/install.sh"
else
  info "Global install not found; skipping (run 'ultimate-skills install' to set it up)"
fi

if [ -f "$REGISTRY" ]; then
  while IFS= read -r project; do
    [ -n "$project" ] || continue
    if [ -f "$project/$MANIFEST_NAME" ]; then
      bash "$scripts/init.sh" "$project"
    else
      registry_remove "$project"
      info "Dropped $project (no longer initialized)"
    fi
  done < <(cat "$REGISTRY")
fi

ok "Update complete"
