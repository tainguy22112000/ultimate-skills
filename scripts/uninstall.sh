#!/usr/bin/env bash
# Remove the global symlinks created by `ultimate-skills install`.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  cat <<EOF
Usage: ultimate-skills uninstall

Removes symlinks under ~/.claude, ~/.cursor and ~/.local/bin that point into this repo.
Projects set up with 'ultimate-skills init' are not touched (use 'ultimate-skills deinit').
EOF
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  "") ;;
  *) die "Unknown option: $1" ;;
esac

for entry in "$HOME/.claude/skills"/* "$HOME/.cursor/skills"/* "$HOME/.claude/rules/$NAMESPACE" "$BIN_LINK"; do
  if is_our_link "$entry"; then
    rm "$entry"
    info "removed $entry"
  fi
done

ok "Uninstalled global links"
