#!/usr/bin/env bash
# Copy selected rules and skills into a project for Claude Code and Cursor.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  cat <<EOF
Usage: ultimate-skills init <project> [selector...] [--force]

Copies rules and skills into <project>/.claude and <project>/.cursor.
Re-running init replaces what a previous init installed.

Selectors (default: everything, or the selectors stored by a previous init):
  rules | rules/<category> | rules/<category>/<name>
  skills | skills/<category> | skills/<category>/<name>

Options:
  --force   Overwrite skills in the project that ultimate-skills did not install
EOF
}

force=0
positional=()
for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    --force) force=1 ;;
    -*) die "Unknown option: $arg" ;;
    *) positional+=("$arg") ;;
  esac
done
[ "${#positional[@]}" -ge 1 ] || { usage; exit 1; }

project="$(abs_dir "${positional[0]}")"
[ "$project" != "$REPO_ROOT" ] || die "Refusing to init the ultimate-skills repo itself"
manifest="$project/$MANIFEST_NAME"

selectors=("${positional[@]:1}")
if [ "${#selectors[@]}" -eq 0 ] && [ -f "$manifest" ]; then
  while IFS= read -r sel; do
    [ -n "$sel" ] && selectors+=("$sel")
  done <<< "$(manifest_values "$manifest" selector)"
fi

items="$(resolve_selectors ${selectors[@]+"${selectors[@]}"})"

if [ -f "$manifest" ]; then
  remove_manifest_paths "$project"
fi

entries=()
for sel in ${selectors[@]+"${selectors[@]}"}; do
  entries+=("selector $sel")
done

while IFS= read -r item; do
  case "$item" in
    rules/*)
      rel="${item#rules/}"
      claude_dest=".claude/rules/$NAMESPACE/$rel.md"
      cursor_dest=".cursor/rules/$NAMESPACE/$rel.mdc"
      mkdir -p "$(dirname "$project/$claude_dest")" "$(dirname "$project/$cursor_dest")"
      cp "$REPO_ROOT/$item.md" "$project/$claude_dest"
      to_mdc "$REPO_ROOT/$item.md" "$project/$cursor_dest"
      entries+=("path $claude_dest" "path $cursor_dest")
      info "rule   $rel"
      ;;
    skills/*)
      name="$(basename "$item")"
      for tool in .claude .cursor; do
        dest="$tool/skills/$name"
        if [ -e "$project/$dest" ] || [ -L "$project/$dest" ]; then
          if [ "$force" -eq 1 ]; then
            rm -rf "${project:?}/$dest"
          else
            warn "Skipping $dest: already exists and was not installed by ultimate-skills (use --force)"
            continue
          fi
        fi
        mkdir -p "$project/$tool/skills"
        cp -R "$REPO_ROOT/$item" "$project/$dest"
        entries+=("path $dest")
      done
      info "skill  $name"
      ;;
  esac
done <<< "$items"

{
  echo "# Managed by ultimate-skills ($REPO_ROOT). Do not edit; use 'ultimate-skills init' / 'ultimate-skills deinit'."
  for entry in ${entries[@]+"${entries[@]}"}; do
    printf '%s\n' "$entry"
  done
} > "$manifest"

registry_add "$project"
ok "Initialized $project"
