# Project Roadmap

## Phase 1: Current Priorities (High Priority)

### Documentation Infrastructure

- [ ] **Manifest-driven README generation**: Build a `generate-extension-readme.sh` script that reads `manifest.json` and `EXTENSION.md` and emits a starter README.md from `.claude/templates/extension-readme-template.md`, filling in commands, skills, agents, and MCP servers automatically
- [ ] **Marketplace metadata for extensions**: Add `marketplace.json` (category, tags, author, license, homepage) to each extension so extensions can be listed in a future extension marketplace
- [ ] **CI enforcement of doc-lint**: Add a GitHub Actions workflow that runs `.claude/scripts/check-extension-docs.sh` on every push and fails the build on doc drift
- [ ] **Integration with /review command**: Have `/review` surface extension-README drift (missing sections, outdated patterns) during codebase review runs, creating follow-up tasks automatically

### Agent System Quality

- [ ] **Extension slim standard enforcement**: Write a lint script that validates extensions against `docs/reference/standards/extension-slim-standard.md` (manifest required fields, size limits, directory conventions)
- [ ] **Agent frontmatter validation**: Add a check that every file in `.claude/agents/` and `.claude/extensions/*/agents/` uses the minimal frontmatter standard (`name`, `description`, optional `model`) with no obsolete fields
- [ ] **Subagent-return reference cleanup**: Sweep remaining `subagent-return-format.md` references in `.claude/context/` (orchestration, processes, formats, schemas) and repoint to `subagent-return.md`. Task 396 fixed the user-facing templates and docs; the deeper context files still carry the old name.

## Phase 2: Medium-Term Improvements

- [ ] **Extension hot-reload**: Allow `<leader>ac` to reload an already-loaded extension without restarting Neovim
- [ ] **Context discovery caching**: Cache the output of the adaptive context query in `~/.claude/cache/` to speed up agent spawn time

## Success Metrics

- All 14 extensions have README.md files (achieved via task 396)
- Doc-lint script exits 0 on every commit
- Zero stale references to removed/renamed files in `.claude/`
- Time from `/task` creation to first artifact < 60 seconds on average
