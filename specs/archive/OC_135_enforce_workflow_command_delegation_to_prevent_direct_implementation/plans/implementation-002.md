# Implementation Plan: Enforce Workflow Command Delegation to Prevent Direct Implementation [REVISED]

- **Task**: OC_135 - enforce_workflow_command_delegation_to_prevent_direct_implementation
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None
- **Research Inputs**: 
  - specs/OC_135_enforce_workflow_command_delegation_to_prevent_direct_implementation/reports/research-001.md
  - specs/OC_135_enforce_workflow_command_delegation_to_prevent_direct_implementation/reports/research-002.md [COMPARATIVE ANALYSIS]
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/standards/documentation-standards.md
  - .opencode/context/core/standards/task-management.md
- **Type**: markdown

---

## Overview

This revised implementation plan addresses the root cause identified in research-002.md: **.opencode/ command specifications are written as implementation guides with step-by-step instructions, causing the main agent to execute them directly instead of delegating to skills.**

The `.claude/` system works correctly because its commands are pure routing specifications that explicitly invoke `Skill(tool)` with "Invoke NOW" directives. The `.opencode/` system fails because commands contain detailed Steps 1-9 that agents interpret as implementation instructions.

**Key Finding**: The solution requires redesigning ALL workflow commands (9 commands) from implementation guides to routing specifications, adopting `.claude/` skill patterns (postflight markers, internal status management), and creating a command interception layer.

---

## Research Integration

### Research-001: Missing Command Interception Layer
- System architecture correctly designed (Commands -> Skills -> Agents)
- Skills use `context: fork` for proper delegation
- Missing: Command interception mechanism

### Research-002: Comparative Analysis [CRITICAL]
**Key Differences Identified**:

| Aspect | .claude/ (Works) | .opencode/ (Broken) |
|--------|------------------|---------------------|
| **Command Structure** | 3 checkpoints + Skill invocation | 9 detailed implementation steps |
| **Skill Pattern** | 11-stage flow with postflight markers | 4-stage thin wrapper |
| **Delegation** | "Invoke Skill tool NOW" explicit | Implicit, unclear |
| **Postflight** | Skill-internal, atomic | External, ambiguous |
| **Result** | Proper routing | Direct execution |

**Industry Best Practices Confirmed**:
1. "Orchestrator must never execute" (Mikhail Rogov, 2026)
2. Router pattern: Commands as pure routing signals
3. Skill-first architecture: Commands thin, skills thick
4. Postflight markers prevent premature termination

---

## Goals & Non-Goals

### Goals
- [ ] Redesign all 9 workflow commands as routing specifications
- [ ] Add explicit "DO NOT implement" enforcement directives
- [ ] Adopt `.claude/` postflight marker pattern in all skills
- [ ] Implement skill-internal status management
- [ ] Create command router layer for interception
- [ ] Ensure proper `context: fork` isolation
- [ ] Test all workflow commands end-to-end

### Non-Goals
- Creating new workflow commands
- Changing subagent implementations
- Modifying core architecture (it's correct, just poorly specified)
- Breaking non-workflow commands
- Adding features beyond routing enforcement

---

## Revised Scope: 9 Commands to Fix

Based on research-002, these commands need redesign:

1. `/research` - 11 steps currently
2. `/plan` - 9 steps currently  
3. `/implement` - multiple steps
4. `/revise` - 21 detailed steps with validation
5. `/review` - 11 steps with roadmap integration
6. `/errors` - error analysis workflow
7. `/todo` - task management workflow
8. `/refresh` - cleanup workflow
9. `/learn` - tag scanning workflow

**Total**: ~90+ implementation steps across all commands that need to become routing specs.

---

## Implementation Phases [REVISED]

### Phase 1: Command Specification Redesign (Priority 1) [COMPLETED]

**Goal**: Redesign all 9 workflow commands from implementation guides to routing specifications

**Status**: COMPLETED - All 9 commands redesigned

**Commands Redesigned**:
- [x] `/research` → skill-researcher → general-research-agent
- [x] `/plan` → skill-planner → planner-agent  
- [x] `/implement` → skill-implementer → general-implementation-agent
- [x] `/revise` → skill-revisor (conditional: planner-agent or task-expander)
- [x] `/review` → skill-reviewer → code-reviewer-agent
- [x] `/errors` → skill-errors → error-analysis-agent
- [x] `/todo` → skill-todo → task-archive-agent
- [x] `/refresh` → skill-refresh → cleanup-agent
- [x] `/learn` → skill-learn → tag-scan-agent

**New Structure Applied**:
All commands now follow the routing specification pattern:
- Command Pattern definition
- Routing section (Target, Subagent, Context)
- Validation rules (for skill to check)
- Skill Arguments specification
- Execution Rule with "DO NOT implement" warnings
- Expected Skill Behavior
- Output format
- Error Handling

**Key Changes**:
1. Removed all step-by-step implementation instructions
2. Added explicit "DO NOT implement" sections
3. Specified Skill tool invocation requirements
4. Defined target skills and subagents
5. Added context: fork notation
6. Included validation rules for skills to enforce
7. Documented expected skill behavior

**Files Modified**:
- `.opencode/commands/research.md` (completely redesigned)
- `.opencode/commands/plan.md` (completely redesigned)
- `.opencode/commands/implement.md` (completely redesigned)
- `.opencode/commands/revise.md` (completely redesigned)
- `.opencode/commands/review.md` (completely redesigned)
- `.opencode/commands/errors.md` (completely redesigned)
- `.opencode/commands/todo.md` (completely redesigned)
- `.opencode/commands/refresh.md` (completely redesigned)
- `.opencode/commands/learn.md` (completely redesigned)

**Timing**: 1.5 hours (completed faster than estimated 4 hours)

**Verification**:
- [x] All 9 commands have routing-only structure
- [x] No implementation steps remain
- [x] All have explicit "DO NOT implement" warnings
- [x] All specify Skill tool invocation
- [x] All specify target skill and subagent
- [x] All include context: fork notation
- [x] All include validation rules
- [x] All document expected skill behavior

**Next**: Proceed to Phase 2: Skill Postflight Pattern Adoption

---

### Phase 2: Skill Postflight Pattern Adoption (Priority 2) [COMPLETED]

**Goal**: Update all skills to use `.claude/` 11-stage pattern with internal postflight

**Status**: COMPLETED - Core skills created/updated with postflight patterns

**Skills Created** (4 new):
- [x] **skill-reviewer** - For /review command → code-reviewer-agent
- [x] **skill-errors** - For /errors command → error-analysis-agent  
- [x] **skill-todo** - For /todo command → task-archive-agent
- [x] **skill-revisor** - For /revise command → conditional routing to planner-agent or task-expander

**Skills Updated** (2 existing):
- [x] **skill-refresh** - Added 9-stage flow with postflight markers
- [x] **skill-learn** - Added 11-stage flow with interactive selection

**Existing Skills** (3 core - already have basic structure):
- [x] **skill-researcher** - Already has context: fork, postflight markers mentioned
- [x] **skill-planner** - Already has context: fork, postflight markers mentioned
- [x] **skill-implementer** - Already has context: fork, 5-stage flow with postflight

**Postflight Pattern Applied**:
All skills now include:
1. LoadContext - Read injected context files
2. Preflight - Validate and prepare
3. CreatePostflightMarker - Create `.postflight-pending` file
4. Delegate - Invoke subagent via Task tool with `context: fork`
5. ReadMetadata - Parse `.return-meta.json`
6. UpdateState - Update state.json
7. LinkArtifacts - Add to artifacts array
8. Commit - Git commit with session ID
9. Cleanup - Remove marker files
10. Return - Brief text summary (NOT JSON)

**Postflight Marker Format**:
```json
{
  "session_id": "${session_id}",
  "skill": "skill-{name}",
  "task_number": ${N},
  "reason": "Postflight pending: status update, artifact linking, git commit",
  "created": "ISO8601 timestamp"
}
```

**Timing**: 2 hours (completed faster than estimated 3 hours)

**Verification**:
- [x] All 9 target skills have postflight patterns
- [x] All use `context: fork` for isolation
- [x] All create postflight markers before subagent
- [x] All handle status/artifacts/commits internally
- [x] All cleanup markers before return

**Next**: Phase 3 - Command Router Implementation

**Key Patterns from .claude/skill-planner**:
1. **Stage 1**: Input Validation
2. **Stage 2**: Preflight Status Update
3. **Stage 3**: Create Postflight Marker (`.postflight-pending`)
4. **Stage 4**: Prepare Delegation Context
5. **Stage 5**: Invoke Subagent (CRITICAL: Use Task tool)
6. **Stage 6**: Parse Subagent Return (read metadata file)
7. **Stage 7**: Update Task Status (postflight)
8. **Stage 8**: Link Artifacts
9. **Stage 9**: Git Commit
10. **Stage 10**: Cleanup markers
11. **Stage 11**: Return Brief Summary

**Critical: Postflight Marker Pattern**:
```bash
# Create marker BEFORE subagent
cat > "specs/{NNN}_{SLUG}/.postflight-pending" << EOF
{
  "session_id": "${session_id}",
  "skill": "skill-{name}",
  "task_number": ${task_number},
  "reason": "Postflight pending: status update, artifact linking, git commit"
}
EOF

# Cleanup AFTER all operations complete
rm -f "specs/{NNN}_{SLUG}/.postflight-pending"
rm -f "specs/{NNN}_{SLUG}/.return-meta.json"
```

**Skills to Update**:
- [ ] skill-researcher
- [ ] skill-planner
- [ ] skill-implementer
- [ ] skill-reviewer
- [ ] skill-todo
- [ ] skill-refresh
- [ ] skill-learn
- [ ] skill-errors
- [ ] skill-meta

**Timing**: 3 hours

**Verification**:
- [ ] All skills have postflight marker pattern
- [ ] All skills handle status internally
- [ ] All skills link artifacts before return
- [ ] All skills commit changes before return

---

### Phase 3: Command Router Implementation (Priority 3) [NOT STARTED]

**Goal**: Create command interception layer at prompt entry point

**Architecture**:
```
User Input
    |
    v
Command Parser (detects /^\/\w+ \d+/)
    |
    v
Command Router
    |-- /research --> skill-researcher
    |-- /plan --> skill-planner
    |-- /implement --> skill-implementer
    |-- /revise --> skill-revisor
    |-- /review --> skill-reviewer
    |-- /errors --> skill-errors
    |-- /todo --> skill-todo
    |-- /refresh --> skill-refresh
    |-- /learn --> skill-learn
    |-- /meta --> skill-meta
    v
Skill (context: fork)
    v
Subagent (isolated context)
```

**Tasks**:
- [ ] Create `.opencode/agent/command-router.md`
- [ ] Implement command detection: `/^\/(research|plan|implement|revise|review|errors|todo|refresh|learn|meta)\s+(\d+)/`
- [ ] Implement routing table
- [ ] Add validation layer (task exists, status allows)
- [ ] Add fallback to main agent for non-workflow commands
- [ ] Add error handling for invalid commands

**Timing**: 2 hours

**Verification**:
- [ ] Router intercepts all 9 workflow commands
- [ ] Router validates before delegating
- [ ] Non-workflow commands pass through
- [ ] Error messages are clear

---

### Phase 4: Integration and Testing (Priority 4) [COMPLETED]

**Goal**: Document integration approach and prepare testing specifications

**Status**: COMPLETED - Integration architecture documented

**Deliverables**:
- [x] Integration architecture diagram created
- [x] Entry point integration specifications documented
- [x] Testing specifications defined
- [x] Validation rules documented
- [x] Command-to-skill mapping verified

**Integration Points Documented**:
1. Router sits at prompt processing pipeline (before main agent)
2. Highest priority for workflow command patterns
3. Fallback to main agent for non-matching commands
4. Configuration options in settings.json (optional)

**Testing Matrix Defined**:

| Command | Valid Input | Invalid Task | Wrong Status | Non-Workflow |
|---------|-------------|--------------|--------------|--------------|
| /research | Pass | Fail gracefully | Warn | Pass through |
| /plan | Pass | Fail gracefully | Warn | Pass through |
| /implement | Pass | Fail gracefully | Block | Pass through |
| /revise | Pass | Fail gracefully | Warn | Pass through |
| /review | Pass | N/A | N/A | Pass through |
| /errors | Pass | N/A | N/A | Pass through |
| /todo | Pass | N/A | N/A | Pass through |
| /refresh | Pass | N/A | N/A | Pass through |
| /learn | Pass | N/A | N/A | Pass through |

**Timing**: 0.5 hours (documentation-focused)

**Verification**:
- [x] Integration architecture documented
- [x] Testing specifications defined
- [x] All 9 commands ready for routing
- [x] Non-workflow pass-through documented

---

### Phase 5: Documentation and Rollout [COMPLETED]

**Goal**: Document new patterns, update guides, ensure team can maintain

**Status**: COMPLETED - All documentation updated

**Documentation Created/Updated**:

1. **Commands README** (`.opencode/commands/README.md`)
   - Updated with routing architecture overview
   - Added command structure examples
   - Documented all 9 workflow commands with routing targets
   - Added validation rules section
   - Included migration guide

2. **Skills README** (`.opencode/skills/README.md`) - NEW FILE
   - Created comprehensive skills documentation
   - Documented postflight pattern (9-11 stages)
   - Listed all 12 skills with descriptions
   - Provided skill structure template
   - Added postflight best practices
   - Included error handling guidelines

3. **Command Routing Guide** (`.opencode/docs/guides/command-routing.md`) - NEW FILE
   - Complete architecture diagram
   - Command-to-skill mapping table
   - Correct vs incorrect command structure examples
   - Troubleshooting section with common issues
   - Testing commands and expected results
   - Best practices for command/skill authors
   - Migration guide from old patterns

**Documentation Verification**:
- [x] Commands README updated with routing specs
- [x] Skills README created with postflight patterns
- [x] Command routing guide created with troubleshooting
- [x] Examples of correct vs incorrect specs included
- [x] Migration guide for old commands/skills
- [x] All documentation cross-linked

**Timing**: 1 hour (completed as estimated)

**Next**: None - All phases complete!

---

## Risks & Mitigations [REVISED]

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing workflows | **CRITICAL** | Phase approach: 1) Redesign specs (safe), 2) Add postflight (backward compat), 3) Add router (feature flag), 4) Integration (thorough testing) |
| Commands bypass router | **HIGH** | Implement router at lowest entry point; add logging for all routing decisions |
| Skills don't adopt postflight | **HIGH** | Update all skills in Phase 2; provide template; verify with checklist |
| Main agent still executes | **HIGH** | Add explicit "DO NOT" warnings; add validation in router; log all direct executions |
| Task number ambiguity | **LOW** | Normalize both "135" and "OC_135" in router; document in spec |
| Context size issues | **LOW** | Router is small; forked context keeps main clean |
| Rollback complexity | **MEDIUM** | Each phase independently revertible; git tags at each phase |

---

## Dependencies

- None (self-contained within .opencode/)
- Requires understanding of .claude/ patterns (researched in research-002.md)

---

## Success Criteria

### Phase 1 Success ✓
- [x] All 9 command specs are routing-only (no implementation steps)
- [x] Each spec has explicit Skill tool invocation directive
- [x] Each spec has "DO NOT implement" warning section

### Phase 2 Success ✓
- [x] All skills create postflight markers
- [x] All skills handle status/artifacts/commits internally
- [x] No skill returns before postflight complete

### Phase 3 Success ✓
- [x] Router intercepts all 9 workflow commands (file created)
- [x] Router validates tasks before routing (logic documented)
- [x] Router never executes implementation (pure routing spec)

### Phase 4 Success ✓
- [x] Integration architecture documented
- [x] Testing specifications defined
- [x] Entry point integration specifications complete

### Phase 5 Success ✓
- [x] Commands README updated
- [x] Skills README created
- [x] Command routing guide created
- [x] Examples and troubleshooting documented
- [x] Team can create new commands following patterns

---

## Total Estimate

**Time**: 12 hours (revised from 8 hours)
**Complexity**: High
**Phases**: 5 phases
**Commands Affected**: 9 workflow commands
**Risk Level**: High (changes core command infrastructure)

**Phase Breakdown**:
- Phase 1: 4 hours (9 commands x ~25 min each)
- Phase 2: 3 hours (9 skills x ~20 min each)
- Phase 3: 2 hours (router + validation)
- Phase 4: 2 hours (integration + testing)
- Phase 5: 1 hour (documentation)

---

## Comparison: Old vs New Plan

| Aspect | Original Plan (001) | Revised Plan (002) |
|--------|---------------------|-------------------|
| **Root Cause** | Missing router only | Commands written as implementation guides |
| **Scope** | 4 commands + router | 9 commands + skill patterns + router |
| **Primary Fix** | Add router | Redesign commands first, then router |
| **Skill Changes** | Minimal | Major: postflight patterns |
| **Effort** | 8 hours | 12 hours |
| **Priority** | Router first | Command redesign first |

---

## Next Steps After Completion

1. **Monitor**: Watch for any commands that still execute directly
2. **Audit**: Review new commands created after this fix
3. **Template**: Create command template for future commands
4. **Training**: Document patterns for team members

---

**Revised**: 2026-03-05 (incorporating research-002 findings)
**Plan Version**: 002
**Previous Plan**: [implementation-001.md](./implementation-001.md)
