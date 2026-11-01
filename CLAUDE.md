# Ultimate Skills

This repo is the source of truth for skills and rules used by Claude Code and Cursor.

- Skills: `skills/<category>/<name>/SKILL.md` (same file serves both tools)
- Rules: `rules/<category>/<name>.md`, written in Claude format (`paths:` frontmatter). Cursor `.mdc` files are generated from them by `to_mdc` in `scripts/lib.sh`; never hand-write `.mdc` files here.
- CLI: `./us <install|uninstall|init|deinit|update>`, implemented in `scripts/` (bash 3.2 compatible, no deps).
- Docs and notes: `docs/`

When changing scripts, test with a throwaway `HOME` and project dir (e.g. `HOME=/tmp/x ./us install`) rather than the real home directory.
