# Implementation Plan: Task #505

- **Task**: 505 - port_missing_core_agents
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: Task description, existing spawn-agent.md port (reference), reviser-agent.md source (.claude/agents/)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, artifact-management.md, agent-frontmatter-standard.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Port the reviser-agent.md from `.claude/agents/` to `.opencode/agent/subagents/` with path adaptations following the patterns established by spawn-agent.md. The spawn-agent has already been ported (task 503), leaving reviser-agent as the only remaining missing core agent. This plan includes verification of extension agent declarations in nvim/nix manifests.

### Research Integration

**From task description and spawn-agent.md reference:**
- spawn-agent.md already ported to `.opencode/agent/subagents/` (192 lines, completed in task 503)
- Path mapping established: `.claude/context/`→`.opencode/context/`, `CLAUDE.md`→`AGENTS.md`, task dirs get `OC_` prefix
- Extension agents: Properly declared in nvim/nix manifests but not installed in subagents directory
- reviser-agent.md source: 192 lines in `.claude/agents/reviser-agent.md`

## Goals & Non-Goals

**Goals**:
- Port reviser-agent.md to `.opencode/agent/subagents/reviser-agent.md`
- Apply path adaptations: `.claude/`→`.opencode/`, `CLAUDE.md`→`AGENTS.md`, add `OC_` prefix for task directories
- Verify extension agent declarations in nvim/nix manifests
- Ensure consistent structure with spawn-agent.md port

**Non-Goals**:
- Modifying agent logic or behavior (pure porting task)
- Porting extension agents (out of scope - separate task)
- Updating skill definitions (out of scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Path mapping inconsistencies | Medium | Low | Follow spawn-agent.md pattern exactly, verify each reference |
| Context file references outdated | Low | Medium | Check that referenced context files exist in .opencode/ |
| Extension agent declaration drift | Low | Low | Document findings, create follow-up task if needed |

## Implementation Phases

### Phase 1: Analyze Source and Reference [COMPLETED]

**Goal**: Understand the source file structure and reference port patterns

**Tasks**:
- [ ] Read `.claude/agents/reviser-agent.md` to identify all path references
- [ ] List all `.claude/` and `CLAUDE.md` references that need updating
- [ ] Verify spawn-agent.md port as reference for path mapping patterns
- [ ] Check which context files exist in `.opencode/context/` vs `.claude/context/`

**Timing**: 20 minutes

**Files to examine**:
- `.claude/agents/reviser-agent.md` - Source file (192 lines)
- `.opencode/agent/subagents/spawn-agent.md` - Reference port
- `.opencode/context/` directory - Verify context file availability

**Verification**:
- Complete list of path references requiring adaptation
- Confirmation of context file mappings

---

### Phase 2: Port reviser-agent.md [COMPLETED]

**Goal**: Create ported version with all path adaptations

**Tasks**:
- [ ] Copy content from `.claude/agents/reviser-agent.md` to `.opencode/agent/subagents/reviser-agent.md`
- [ ] Update context references:
  - `@.claude/context/` → `@.opencode/context/`
  - `@.claude/CLAUDE.md` → `@.opencode/AGENTS.md`
  - `specs/{NNN}_{SLUG}/` → `specs/OC_{NNN}_{SLUG}/`
- [ ] Update delegation_path examples to use `.opencode/` paths
- [ ] Update metadata file path references
- [ ] Verify frontmatter is preserved (name, description, model)

**Timing**: 30 minutes

**Files to modify**:
- `.opencode/agent/subagents/reviser-agent.md` - Create new file

**Verification**:
- All `.claude/` references updated to `.opencode/`
- All `CLAUDE.md` references updated to `AGENTS.md`
- Task directory format includes `OC_` prefix
- File structure matches spawn-agent.md port pattern

---

### Phase 3: Verify Extension Agent Declarations [COMPLETED]

**Goal**: Confirm extension agents are properly declared in manifests

**Tasks**:
- [ ] Read nvim extension manifest (`.opencode/extensions/nvim/manifest.json`)
- [ ] Read nix extension manifest (`.opencode/extensions/nix/manifest.json`)
- [ ] Verify agent declarations reference correct paths
- [ ] Document any discrepancies or issues found

**Timing**: 20 minutes

**Files to examine**:
- `.opencode/extensions/nvim/manifest.json` - Agent declarations
- `.opencode/extensions/nix/manifest.json` - Agent declarations

**Verification**:
- All declared agents have proper metadata
- Paths in declarations are consistent with actual file locations
- No orphaned declarations or missing references

---

### Phase 4: Final Verification [COMPLETED]

**Goal**: Validate the port and document completion

**Tasks**:
- [ ] Read back `.opencode/agent/subagents/reviser-agent.md` to verify completeness
- [ ] Run grep to confirm no remaining `.claude/` or `CLAUDE.md` references
- [ ] Verify file is 192 lines (matches source)
- [ ] Create summary of changes made

**Timing**: 20 minutes

**Verification commands**:
```bash
# Check for any remaining old-style references
grep -n "\.claude/" .opencode/agent/subagents/reviser-agent.md || echo "No .claude/ references found"
grep -n "CLAUDE\.md" .opencode/agent/subagents/reviser-agent.md || echo "No CLAUDE.md references found"

# Verify line count
wc -l .opencode/agent/subagents/reviser-agent.md
```

**Verification criteria**:
- [ ] File created at correct path
- [ ] All path references updated
- [ ] Line count matches source (192 lines)
- [ ] Frontmatter intact
- [ ] No broken references

---

## Testing & Validation

- [ ] Verify reviser-agent.md loads without errors
- [ ] Confirm all context references resolve to existing files
- [ ] Cross-check with spawn-agent.md port for consistency
- [ ] Document any extension agent declaration issues found

## Artifacts & Outputs

- `.opencode/agent/subagents/reviser-agent.md` - Ported agent definition (192 lines)
- Extension agent verification report (inline in summary)

## Rollback/Contingency

If port issues discovered:
1. Delete `.opencode/agent/subagents/reviser-agent.md`
2. Re-analyze source file for missed adaptations
3. Re-port with corrected mappings
4. Document any path mapping clarifications needed

## Completion Summary Template

When completing this task, provide:
- Lines ported: 192
- Path adaptations applied: [list]
- Extension agent status: [verified/issues found]
- Any follow-up tasks needed: [if applicable]
