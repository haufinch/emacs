# Agent Instructions

## What this repo is

A from-scratch GNU Emacs configuration, replacing Positron (a VS Code fork) as
primary editor. The plan, build order and open decisions live in beads — start
with `bd ready` and `bd list --status=open`; the rationale for settled choices
is in closed `decision` beads. This file holds the working rules.

## Environment

- macOS, Apple Silicon
- Emacs from `emacs-plus` (Homebrew), native-comp enabled, 30.2 line
- Loaded via `emacs --init-directory=~/.config/emacs` — the user's real
  `~/.emacs.d` is a separate legacy config and is **off limits**
- Homebrew, iTerm2, `rig` for R versions, `renv` for project libraries
- Target workflow: R, Shiny, TypeScript, heavy git worktree use
- The user also works on Posit Workbench (remote, browser sessions) — don't
  assume a local GUI-only environment

## Hard rules

1. **Built-in before third-party.** `project.el` before projectile, `eglot`
   before lsp-mode, `tab-bar` before workspace packages, `dired` before a file
   tree, `use-package` (built in since 29) always. If you add a package,
   state in one line what built-in facility was insufficient and why.
2. **Every setting gets a why.** One-line comment above any non-obvious `setq`,
   hook or keybinding. Check the docstring before writing it. Config without a
   stated reason gets deleted.
3. **No config frameworks.** No Doom, Spacemacs, Prelude, Crafted Emacs, no
   copying large blocks from published configs. Small, understood, incremental.
4. **Respect the layer order.** The build layers are sequential epics in beads
   with blocking deps — `bd ready` shows what is unblocked. Don't add R tooling
   while the completion layer is still unsettled. If asked for something out of
   order, say so and confirm before proceeding.
5. **Don't touch `~/.emacs.d`** or anything outside this repo and the configured
   init directory.
6. **Prefer deleting to adding.** The point of the rebuild is a smaller, better
   understood config, not parity with Positron.

## Verifying changes

Never claim config works without running it. Available checks:

```sh
# byte-compile warnings — catches typos, unbound vars, bad arg counts
emacs -Q -batch -f batch-byte-compile lisp/*.el

# does the whole config load cleanly from a cold start?
emacs --init-directory=/tmp/emacs-test -batch -l init.el

# start a real session against the config
emacs --init-directory=~/.config/emacs
```

For anything with logic (worktree helpers, project detection, Shiny launching),
write an ERT test and run it headless. Pure `setq` blocks don't need tests.

Elisp gotchas worth remembering here: `lexical-binding: t` in every file header;
`add-hook` with a lambda can't be removed cleanly — name the function; check
whether a `defcustom` needs `:set` rather than plain assignment.

## Conventions

- `use-package` for every package, with `:defer` unless load order requires
  otherwise
- `no-littering` is active — write generated paths through it, not hardcoded
- Keep `init.el` monolithic until it passes ~300 lines, then split into `lisp/`
- Two-space indent, standard elisp style, `;;;` section headers
- One commit per capability, imperative subject line, body says why not what.
  Small commits matter here — `git bisect` is the primary debugging tool when a
  package update breaks startup.

## Working style

- Be direct. Don't apologize. Don't pad.
- Don't invent package names, function names or options — check the docstring,
  the package's README, or say you're unsure.
- If a request would add complexity the user will have to maintain, say so
  before implementing it.
- Ask before large refactors or before introducing a new dependency.

## Non-Interactive Shell Commands

**ALWAYS use non-interactive flags** with file operations to avoid hanging on confirmation prompts.

Shell commands like `cp`, `mv`, and `rm` may be aliased to include `-i` (interactive) mode on some systems, causing the agent to hang indefinitely waiting for y/n input.

**Use these forms instead:**
```bash
# Force overwrite without prompting
cp -f source dest           # NOT: cp source dest
mv -f source dest           # NOT: mv source dest
rm -f file                  # NOT: rm file

# For recursive operations
rm -rf directory            # NOT: rm -r directory
cp -rf source dest          # NOT: cp -r source dest
```

**Other commands that may prompt:**
- `scp` - use `-o BatchMode=yes` for non-interactive
- `ssh` - use `-o BatchMode=yes` to fail instead of prompting
- `apt-get` - use `-y` flag
- `brew` - use `HOMEBREW_NO_AUTO_UPDATE=1` env var

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:970c3bf2 -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/SYNC_CONCEPTS.md for details and anti-patterns.

## Agent Context Profiles

The managed Beads block is task-tracking guidance, not permission to override repository, user, or orchestrator instructions.

- **Conservative (default)**: Use `bd` for task tracking. Do not run git commits, git pushes, or Dolt remote sync unless explicitly asked. At handoff, report changed files, validation, and suggested next commands.
- **Minimal**: Keep tool instruction files as pointers to `bd prime`; use the same conservative git policy unless active instructions say otherwise.
- **Team-maintainer**: Only when the repository explicitly opts in, agents may close beads, run quality gates, commit, and push as part of session close. A current "do not commit" or "do not push" instruction still wins.

## Session Completion

This protocol applies when ending a Beads implementation workflow. It is subordinate to explicit user, repository, and orchestrator instructions.

1. **File issues for remaining work** - Create beads for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **Handle git/sync by active profile**:
   ```bash
   # Conservative/minimal/default: report status and proposed commands; wait for approval.
   git status

   # Team-maintainer opt-in only, unless current instructions forbid it:
   git pull --rebase
   bd dolt push
   git push
   git status
   ```
5. **Hand off** - Summarize changes, validation, issue status, and any blocked sync/commit/push step

**Critical rules:**
- Explicit user or orchestrator instructions override this Beads block.
- Do not commit or push without clear authority from the active profile or the current user request.
- If a required sync or push is blocked, stop and report the exact command and error.
<!-- END BEADS INTEGRATION -->

