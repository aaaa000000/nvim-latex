# .claude/commands/ — Legacy Mirror Directory

**Status**: DEPRECATED

These command files are legacy copies from an earlier version of the system. The active command definitions are in `.opencode/commands/`.

## Differences from Active Commands

- `.claude/commands/` uses old extension paths (`.claude/extensions/`)
- `.claude/commands/` lacks manifest-discovery improvements (compound key fallback, manifest count warnings)
- `.claude/commands/` has shorter Anti-Bypass skill lists
- `.claude/commands/` uses `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` instead of `OPENCODE_EXPERIMENTAL_AGENT_TEAMS`

## Action Required

If you are using OpenCode, use `.opencode/commands/` instead. This directory may be removed or converted to symlinks in a future task.
