# Shared helpers for Ultimate Skills scripts. Sourced, not executed.
# Bash 3.2 compatible (macOS default), no external deps beyond POSIX tools.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
NAMESPACE="ultimate-skills"
MANIFEST_NAME=".ultimate-skills"
STATE_DIR="$HOME/.ultimate-skills"
REGISTRY="$STATE_DIR/projects"

info() { printf '  %s\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }

# --- Catalog -----------------------------------------------------------------
# Items are identified by repo-relative ids without extension:
#   rules/<category>/<name>    -> rules/<category>/<name>.md
#   skills/<category>/<name>   -> skills/<category>/<name>/SKILL.md

list_rules() {
  (cd "$REPO_ROOT" && find rules -mindepth 2 -maxdepth 2 -type f -name '*.md' | sed 's/\.md$//' | sort)
}

list_skills() {
  (cd "$REPO_ROOT" && find skills -mindepth 3 -maxdepth 3 -type f -name SKILL.md | sed 's|/SKILL\.md$||' | sort)
}

list_items() { list_rules; list_skills; }

# Expand selectors (e.g. "rules/frontend", "skills/engineering/clean-code")
# into item ids. No selectors means everything.
resolve_selectors() {
  local all sel matched item
  all="$(list_items)"
  if [ $# -eq 0 ]; then
    printf '%s\n' "$all"
    return
  fi
  for sel in "$@"; do
    sel="${sel%/}"
    sel="${sel%.md}"
    matched=0
    while IFS= read -r item; do
      case "$item" in
        "$sel"|"$sel"/*) printf '%s\n' "$item"; matched=1 ;;
      esac
    done <<< "$all"
    [ "$matched" -eq 1 ] || die "Selector matched nothing: $sel"
  done | awk '!seen[$0]++'
}

# --- Rule conversion ---------------------------------------------------------
# Convert a Claude rule (.md with optional `paths:` / `description:` frontmatter)
# into a Cursor rule (.mdc with description / globs / alwaysApply).
# Brace globs like **/*.{ts,tsx} are expanded because Cursor splits globs on commas.
to_mdc() {
  local src="$1" dest="$2"
  awk -v q="'" '
    function expand(p,    pre, post, inner, n, i, alts, out, s) {
      if (!match(p, /\{[^}]*\}/)) return p
      pre = substr(p, 1, RSTART - 1)
      inner = substr(p, RSTART + 1, RLENGTH - 2)
      post = substr(p, RSTART + RLENGTH)
      n = split(inner, alts, ",")
      out = ""
      for (i = 1; i <= n; i++) {
        s = expand(pre alts[i] post)
        out = out (out == "" ? "" : ",") s
      }
      return out
    }
    function unquote(s) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
      if (s ~ ("^\"") || s ~ ("^" q)) s = substr(s, 2, length(s) - 2)
      return s
    }
    NR == 1 && $0 == "---" { fm = 1; next }
    fm && $0 == "---"      { fm = 0; next }
    fm {
      if ($0 ~ /^paths:/) { inpaths = 1; next }
      if (inpaths && $0 ~ /^[[:space:]]*-/) {
        p = $0; sub(/^[[:space:]]*-[[:space:]]*/, "", p)
        p = expand(unquote(p))
        globs = globs (globs == "" ? "" : ",") p
        next
      }
      inpaths = 0
      if ($0 ~ /^description:/) { desc = $0; sub(/^description:[[:space:]]*/, "", desc) }
      next
    }
    {
      body = body $0 "\n"
      if (heading == "" && $0 ~ /^# /) heading = substr($0, 3)
    }
    END {
      if (desc == "") desc = heading
      print "---"
      if (desc != "") print "description: " desc
      if (globs != "") { print "globs: " globs; print "alwaysApply: false" }
      else print "alwaysApply: true"
      print "---"
      printf "%s", body
    }
  ' "$src" > "$dest"
}

# --- Symlinks ----------------------------------------------------------------

# True if $1 is a symlink pointing into this repo.
is_our_link() {
  [ -L "$1" ] || return 1
  case "$(readlink "$1")" in
    "$REPO_ROOT"/*) return 0 ;;
    *) return 1 ;;
  esac
}

# --- Project registry --------------------------------------------------------

registry_add() {
  mkdir -p "$STATE_DIR"
  touch "$REGISTRY"
  grep -qxF "$1" "$REGISTRY" || printf '%s\n' "$1" >> "$REGISTRY"
}

registry_remove() {
  [ -f "$REGISTRY" ] || return 0
  local tmp
  tmp="$(mktemp)"
  grep -vxF "$1" "$REGISTRY" > "$tmp" || true
  mv "$tmp" "$REGISTRY"
}

# --- Project manifest --------------------------------------------------------
# Format (one entry per line):
#   selector <selector>   selectors passed to init (absent = everything)
#   path <relative path>  files/dirs installed into the project

abs_dir() {
  [ -d "$1" ] || die "Not a directory: $1"
  (cd "$1" && pwd -P)
}

manifest_values() {
  local manifest="$1" key="$2"
  [ -f "$manifest" ] || return 0
  sed -n "s/^$key //p" "$manifest"
}

# Delete every path recorded in the project's manifest, then prune
# directories left empty. Only paths under .claude/ or .cursor/ are touched.
remove_manifest_paths() {
  local project="$1" manifest="$1/$MANIFEST_NAME" rel dir
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    case "$rel" in
      /*|*..*) warn "Skipping unsafe manifest path: $rel"; continue ;;
      .claude/*|.cursor/*) rm -rf "${project:?}/$rel" ;;
      *) warn "Skipping unexpected manifest path: $rel" ;;
    esac
  done <<< "$(manifest_values "$manifest" path)"

  for dir in .claude/rules/$NAMESPACE .cursor/rules/$NAMESPACE; do
    if [ -d "$project/$dir" ]; then
      find "$project/$dir" -depth -type d -empty -delete
    fi
  done
  for dir in .claude/rules .cursor/rules .claude/skills .cursor/skills .claude .cursor; do
    rmdir "$project/$dir" 2>/dev/null || true
  done
}
