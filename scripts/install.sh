#!/usr/bin/env bash
# Symlink skills and rules into the user-level Claude Code and Cursor config.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  cat <<EOF
Usage: ultimate-skills install [--force]

Links into your home directory:
  skills/<category>/<name>  -> ~/.claude/skills/<name>, ~/.cursor/skills/<name>
  rules/                    -> ~/.claude/rules/$NAMESPACE
  ultimate-skills (CLI)     -> ~/.local/bin/ultimate-skills

Cursor has no file-based global rules, so rules are only linked for Claude.
Use 'ultimate-skills init <project>' to get Cursor rules in a project.

Options:
  --force   Replace existing entries that don't belong to ultimate-skills
EOF
}

force=0
for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    --force) force=1 ;;
    *) die "Unknown option: $arg" ;;
  esac
done

# Link $1 (source) at $2 (target). Dangling links and our own links are
# refreshed; anything else is a conflict unless --force.
link() {
  local src="$1" target="$2"
  if [ -L "$target" ] && { is_our_link "$target" || [ ! -e "$target" ]; }; then
    rm "$target"
  elif [ -e "$target" ] || [ -L "$target" ]; then
    if [ "$force" -eq 1 ]; then
      rm -rf "$target"
    else
      warn "Skipping $target: already exists ($( [ -L "$target" ] && readlink "$target" || echo "not a link")). Use --force to replace."
      return 0
    fi
  fi
  mkdir -p "$(dirname "$target")"
  ln -s "$src" "$target"
  info "linked $target"
}

# Remove our links whose source no longer exists (e.g. a deleted skill).
prune() {
  local dir="$1" entry
  [ -d "$dir" ] || return 0
  for entry in "$dir"/*; do
    if is_our_link "$entry" && [ ! -e "$entry" ]; then
      rm "$entry"
      info "pruned $entry"
    fi
  done
}

legacy="$HOME/.claude/rules/cursor-rules"
if is_our_link "$legacy" || { [ -L "$legacy" ] && [ ! -e "$legacy" ]; }; then
  rm "$legacy"
  info "removed legacy link $legacy"
fi

prune "$HOME/.claude/skills"
prune "$HOME/.cursor/skills"

while IFS= read -r item; do
  name="$(basename "$item")"
  link "$REPO_ROOT/$item" "$HOME/.claude/skills/$name"
  link "$REPO_ROOT/$item" "$HOME/.cursor/skills/$name"
done <<< "$(list_skills)"

link "$REPO_ROOT/rules" "$HOME/.claude/rules/$NAMESPACE"
link "$REPO_ROOT/ultimate-skills" "$BIN_LINK"

case ":$PATH:" in
  *":$(dirname "$BIN_LINK"):"*) ;;
  *) warn "$(dirname "$BIN_LINK") is not on your PATH; add it to use 'ultimate-skills' anywhere" ;;
esac

ok "Installed globally (Cursor rules are per-project: use 'ultimate-skills init')"
