# Ultimate Skills

One place to write and manage **skills** and **rules** for [Claude Code](https://claude.com/claude-code) and [Cursor](https://cursor.com), plus a small CLI (`us`) to install them globally or into individual projects.

## Layout

```
skills/<category>/<name>/SKILL.md   # Agent skills (same format for Claude and Cursor)
rules/<category>/<name>.md          # Rules, written once in Claude format
scripts/                            # CLI implementation (bash, no dependencies)
docs/                               # Notes and reference material
us                                  # CLI entry point
```

The layout follows [`mattpocock/skills`](https://github.com/mattpocock/skills), so `npx skills add <owner>/ultimate-skills` also works for the skills.

## Writing rules

Write each rule once as Markdown, using Claude's frontmatter:

```markdown
---
description: Optional, used for the Cursor rule   # defaults to the first "# " heading
paths:
  - "**/*.{ts,tsx}"
---

# TypeScript Rules
...
```

When a rule is installed into a project, a Cursor `.mdc` file is generated from it:

| Claude source            | Cursor output                                     |
| ------------------------ | ------------------------------------------------- |
| `paths: ["**/*.{ts,tsx}"]` | `globs: **/*.ts,**/*.tsx` + `alwaysApply: false` |
| no `paths`               | `alwaysApply: true`                               |

## Commands

```bash
./us install            # symlink skills + rules into ~/.claude and ~/.cursor
./us uninstall          # remove those symlinks
./us init ~/code/app    # copy everything into a project's .claude/ and .cursor/
./us init ~/code/app rules/frontend skills/engineering/clean-code
./us deinit ~/code/app  # remove only what init added
./us update             # git pull, then refresh the global install and every init'ed project
```

Run `./us <command> -h` for details. To call it from anywhere: `ln -s "$PWD/us" /usr/local/bin/us`.

### install / uninstall (global)

- `skills/<category>/<name>` → `~/.claude/skills/<name>` and `~/.cursor/skills/<name>`
- `rules/` → `~/.claude/rules/ultimate-skills`
- Cursor has no file-based global rules. To get Cursor rules, use `init` per project.
- Existing entries that aren't ours (for example, skills installed by `npx skills`) are skipped with a warning. Pass `--force` to replace them.
- Links are symlinks, so edits in this repo take effect immediately.

### init / deinit (per project)

- Files are copied rather than symlinked, so they can be committed and shared with teammates:
  - `.claude/rules/ultimate-skills/<category>/<name>.md`
  - `.cursor/rules/ultimate-skills/<category>/<name>.mdc`
  - `.claude/skills/<name>/` and `.cursor/skills/<name>/`
- Selectors: `rules`, `rules/<category>`, `rules/<category>/<name>`, and the same forms for `skills`. With no selectors, everything is installed.
- `<project>/.ultimate-skills` records the selectors and every installed path. Re-running `init` without selectors reuses the stored ones. `deinit` removes exactly those paths.
- Initialized projects are tracked in `~/.ultimate-skills/projects` so that `update` can refresh them.

### update

1. Runs `git pull --ff-only` (`--no-pull` skips this).
2. Re-links the global install, if one is present, and prunes links to skills that were removed.
3. Re-runs `init` for each tracked project, keeping its selectors.

## Adding a skill or rule

1. Create `skills/<category>/<name>/SKILL.md` or `rules/<category>/<name>.md`.
2. Run `./us update --no-pull`, or wait for your next `./us update`.
