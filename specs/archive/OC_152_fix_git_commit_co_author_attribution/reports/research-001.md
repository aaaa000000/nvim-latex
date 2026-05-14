# Research Report: Fix git commit co-author attribution showing Claude Opus instead of actual model

**Task**: OC_152 - fix_git_commit_co_author_attribution  
**Started**: 2026-03-05T00:00:00Z  
**Completed**: 2026-03-05T00:15:00Z  
**Effort**: 1 hour  
**Priority**: Medium  
**Dependencies**: None  
**Sources/Inputs**:
  - `.opencode/commands/implement.md`
  - `.opencode/commands/plan.md`
  - `.opencode/commands/research.md`
  - `.opencode/commands/review.md`
  - `.opencode/context/core/checkpoints/checkpoint-commit.md`
  - `.opencode/skills/skill-git-workflow/SKILL.md`
  - `.opencode/settings.json`
  - Git commit history
**Artifacts**:
  - `specs/OC_152_fix_git_commit_co_author_attribution/reports/research-001.md` (this report)
**Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

---

## Executive Summary

- **Root cause identified**: Co-author attribution is hardcoded in command files with inconsistent values across the codebase
- **Primary inconsistency**: `.opencode/commands/` files use "Claude Opus 4.5" while checkpoint standards use "OpenCode"
- **Files affected**: 4 command files contain hardcoded "Claude Opus 4.5" co-author strings
- **Git history confirms**: Recent commits show "Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
- **Recommendation**: Standardize all co-author attributions to "OpenCode <noreply@opencode.ai>" OR remove co-author entirely
- **No dynamic model detection exists**: The system does not currently detect which AI model is actually being used (Kimi K2.5 vs Claude Opus)

---

## Context & Scope

### Problem Statement
Git commits in the OpenCode system incorrectly attribute co-authorship to "Claude Opus 4.5" even when the actual model being used is Kimi K2.5. This creates misleading commit metadata.

### Scope of Investigation
1. Locate all instances of co-author strings in the codebase
2. Identify where git commits with co-author attribution are created
3. Determine if model detection is possible
4. Assess whether to fix attribution or remove it entirely

---

## Findings

### Finding 1: Inconsistent Co-Author Attribution Across Files

The codebase contains **two different co-author attributions**:

| Location | Co-Author String |
|----------|------------------|
| `.opencode/commands/implement.md` (line 180) | `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>` |
| `.opencode/commands/plan.md` (line 167) | `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>` |
| `.opencode/commands/research.md` (line 198) | `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>` |
| `.opencode/commands/review.md` (line 169) | `Co-Authored-By: OpenCode <noreply@opencode.ai>` |
| `.opencode/context/core/checkpoints/checkpoint-commit.md` | `Co-Authored-By: OpenCode <noreply@opencode.ai>` |
| `.opencode/skills/skill-git-workflow/SKILL.md` | `Co-Authored-By: OpenCode <noreply@opencode.ai>` |

### Finding 2: Git History Confirms the Issue

Recent commits in the git history show the incorrect attribution:

```
commit d2e83384a5313c7af4870a8f07f5e2ecc427a92c
Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

Older commits (before the inconsistency was introduced) show the correct attribution:

```
commit 66f83f01...
Co-Authored-By: OpenCode <noreply@opencode.ai>
```

### Finding 3: No Dynamic Model Detection

The `.opencode/settings.json` file contains a static model setting:
```json
{
  "model": "sonnet"
}
```

However, this is **not** used to populate the co-author string. The co-author strings are **hardcoded** in the command files and are not dynamically generated based on the actual model being used.

**Environment variables checked**:
- No `OPENCODE_MODEL` or similar variable exists for co-author generation
- The `model` field in settings.json is not referenced in commit message generation

### Finding 4: Command Files Are the Source of Commits

The command files (`implement.md`, `plan.md`, `research.md`, `review.md`) contain the actual git commit commands with embedded co-author strings. These are the files that need to be modified to fix the issue.

Example from `.opencode/commands/implement.md`:
```bash
git commit -m "task N: complete implementation

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

### Finding 5: 14 Total Files Contain "Claude Opus 4.5" String

A grep search revealed 14 files in `.opencode/` containing the string "Claude Opus 4.5":
- 4 command files (`implement.md`, `plan.md`, `research.md`, `review.md`)
- 3 skill files (`skill-researcher`, `skill-planner`, `skill-implementer`)
- 1 agent file (`general-implementation-agent.md`)
- 6 extension files (nix, web, filetypes)

### Finding 6: Skill Documentation vs. Active Code

The `.opencode/skills/skill-git-workflow/SKILL.md` shows the correct "OpenCode" attribution in its documentation/examples, but this is **reference documentation only**. The actual commit commands are in the command files which contain the incorrect "Claude Opus 4.5" strings.

---

## Decisions

### Decision 1: Attribution Strategy
**Options considered**:
1. Fix attribution to show actual model (Kimi K2.5) - **NOT FEASIBLE**: No dynamic model detection exists
2. Standardize all to "OpenCode <noreply@opencode.ai>" - **RECOMMENDED**: Consistent with OpenCode branding
3. Remove co-author attribution entirely - **ALTERNATIVE**: Simpler, no attribution concerns

**Decision**: Standardize to "OpenCode <noreply@opencode.ai>" for consistency with the OpenCode tool branding.

### Decision 2: Scope of Changes
**Options considered**:
1. Fix only the 4 command files that create actual commits
2. Fix all 14 files containing "Claude Opus 4.5" for consistency

**Decision**: Fix all 14 files to ensure consistency across the entire codebase. Documentation should match actual behavior.

---

## Recommendations

### Primary Recommendation: Standardize to OpenCode Attribution

**Priority**: High  
**Effort**: Low (simple string replacements)

Replace all instances of:
```
Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

With:
```
Co-Authored-By: OpenCode <noreply@opencode.ai>
```

**Files to modify** (14 total):
1. `.opencode/commands/implement.md`
2. `.opencode/commands/plan.md`
3. `.opencode/commands/research.md`
4. `.opencode/commands/review.md`
5. `.opencode/skills/skill-researcher/SKILL.md`
6. `.opencode/skills/skill-planner/SKILL.md`
7. `.opencode/skills/skill-implementer/SKILL.md`
8. `.opencode/agent/subagents/general-implementation-agent.md`
9. `.opencode/extensions/filetypes/commands/convert.md`
10. `.opencode/extensions/nix/skills/skill-nix-research/SKILL.md`
11. `.opencode/extensions/nix/skills/skill-nix-implementation/SKILL.md`
12. `.opencode/extensions/nix/agents/nix-implementation-agent.md`
13. `.opencode/extensions/web/skills/skill-web-research/SKILL.md`
14. `.opencode/extensions/web/skills/skill-web-implementation/SKILL.md`
15. `.opencode/extensions/web/agents/web-implementation-agent.md`

### Alternative Recommendation: Remove Co-Author Attribution

**Priority**: Medium  
**Effort**: Low  

If maintaining accurate attribution is not important, remove all `Co-Authored-By` lines entirely from commit messages. This eliminates any confusion about which AI model was used.

### Future Enhancement: Dynamic Model Detection

**Priority**: Low  
**Effort**: Medium  

Consider implementing dynamic model detection that:
1. Reads the actual model from environment or API response
2. Generates appropriate co-author attribution (e.g., "Kimi K2.5" when using that model)
3. Falls back to "OpenCode" when model cannot be determined

This would require integration with the OpenCode tool's model detection capabilities.

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking git commit functionality | Low | High | Test commit after changes; the string replacement is in commit message body only |
| Missing files in replacement | Medium | Low | Comprehensive grep search already performed; double-check before finalizing |
| Future reintroduction of incorrect attribution | Medium | Medium | Document correct attribution in `.opencode/context/core/standards/git-workflow.md` |
| User confusion about OpenCode vs actual model | Medium | Low | Add comment explaining that "OpenCode" represents the tool, not the specific model |

---

## Appendix

### A. Git Commands Used in Investigation

```bash
# Find commits with co-author attribution
git log --oneline -20 --grep="Co-Authored-By"

# Check recent commit details
git log -1 --format=full d2e83384

# Search for co-author strings in codebase
grep -r "Co-Authored-By" .opencode/
grep -r "Claude Opus 4\.5" .opencode/
```

### B. Related Configuration Files

- `.opencode/settings.json` - Contains static model setting ("sonnet") but not used for co-author
- `.opencode/context/core/checkpoints/checkpoint-commit.md` - Contains correct "OpenCode" attribution standard
- `.opencode/skills/skill-git-workflow/SKILL.md` - Reference documentation with correct attribution

### C. Context Knowledge Candidates

No new domain-general knowledge identified. This is a project-specific configuration issue.
