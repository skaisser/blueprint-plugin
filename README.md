<div align="center">

# Blueprint SDLC

### Claude Code Plugin

**Turn Claude Code into a disciplined engineering team.**

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet)](https://github.com/skaisser/blueprint-plugin)

</div>

---

## Install (2 seconds)

```
/plugin marketplace add skaisser/blueprint-plugin
/plugin install blueprint
```

That's it. 27 skills, audit hooks, MCP servers, and status line — all active instantly.

## What's Included

| Component | What it does |
|-----------|-------------|
| **27 slash commands** | Full SDLC pipeline: `/backlog` → `/plan` → `/plan-review` → `/plan-approved` → `/plan-check` → `/pr` → `/review` → `/address-pr` → `/finish` |
| **Audit hook** | 15 enforcement rules on every tool call — prevents drift, enforces commit format, blocks dangerous commands |
| **MCP servers** | Context7 (live library docs) + Sequential Thinking (structured reasoning) — auto-registered |
| **Status line** | Context usage bar, estimated time remaining, git branch, code changes |
| **Templates** | Git hooks (commit format, branch protection), GitHub Actions (PR review, tests), project scaffold |

## The Pipeline

```
/backlog → /plan → /plan-review → /plan-approved → /plan-check → /pr → /review → /address-pr → /finish
    B         L         U              E               P          R        I           N            T
```

Plus automation: `/flow` (guided), `/flow-auto` (zero-touch), `/batch-flow` (multi-plan).

## All 27 Skills

| Category | Skills |
|----------|--------|
| **Pipeline** | `/backlog`, `/plan`, `/plan-review`, `/plan-approved`, `/plan-check`, `/pr`, `/review`, `/address-pr`, `/finish` |
| **Automation** | `/flow`, `/flow-auto`, `/flow-auto-wt`, `/batch-flow` |
| **Fast Track** | `/quick`, `/hotfix`, `/resume` |
| **Git & PR** | `/bp-commit`, `/bp-ship`, `/bp-push`, `/bp-branch` |
| **Testing** | `/bp-test`, `/bp-tdd-review` |
| **Setup** | `/start`, `/bp-context`, `/bp-status`, `/complete` |
| **Meta** | `/skill-creator` |

## CLI Binary (Optional but Recommended)

The audit hook requires the Blueprint CLI binary. It **auto-installs on first use**, or install manually:

```bash
# Via Homebrew
brew tap skaisser/tap
brew install blueprint

# Or via the setup script
bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh"
```

### CLI Commands

```bash
blueprint audit       # Pre-tool-use enforcement (called by hook)
blueprint status      # Show SDLC status
blueprint update      # Self-update from GitHub Releases
blueprint meta        # Plan metadata as JSON
blueprint sync        # Sync plan frontmatter
blueprint commit      # Validated commit
blueprint backlog     # Manage backlog items
```

## How It Works

1. **Plugin install** registers 27 slash commands + hooks + MCP servers
2. **First tool call** triggers the audit hook, which auto-downloads the CLI binary
3. **Every subsequent tool call** is validated by the 15-rule audit engine
4. **Skills guide Claude** through the full SDLC — from idea capture to merged PR

## Contributing

The plugin is auto-synced from the [main Blueprint repo](https://github.com/skaisser/blueprint). To contribute:

1. Fork [skaisser/blueprint](https://github.com/skaisser/blueprint)
2. Make your changes
3. Submit a PR to the main repo
4. Changes are automatically synced to this plugin repo on release

## License

Apache 2.0 — see [LICENSE](LICENSE)
