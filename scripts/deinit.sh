#!/usr/bin/env bash
# Remove everything a previous `ultimate-skills init` installed into a project.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  cat <<EOF
Usage: ultimate-skills deinit <project>

Removes the rules and skills that 'ultimate-skills init' copied into <project>,
using <project>/$MANIFEST_NAME. Files you added yourself are left alone.
EOF
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  "") usage; exit 1 ;;
esac

project="$(abs_dir "$1")"
manifest="$project/$MANIFEST_NAME"
[ -f "$manifest" ] || die "No $MANIFEST_NAME manifest in $project (was it initialized?)"

remove_manifest_paths "$project"
rm -f "$manifest"
registry_remove "$project"
ok "Deinitialized $project"
