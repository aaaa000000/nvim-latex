# Research Report: Progressive Context Disclosure and Context Injection Optimization

**Task**: OC_137 - investigate_and_fix_planner_agent_format_compliance_issue  
**Report**: research-003.md (Context injection strategy analysis)  
**Date**: 2026-03-06  
**Status**: [COMPLETED]  
**Focus**: Context injection patterns, progressive disclosure, and optimization opportunities

---

## Executive Summary

The OpenCode system currently uses a hybrid Push/Pull context loading model that provides a solid foundation but has opportunities for optimization. This research identifies specific areas where context injection happens in abundance rather than with surgical precision, leading to unnecessary context bloat. The report provides actionable recommendations for implementing tiered progressive disclosure that maintains system reliability while reducing context window usage.

**Key Finding**: The system successfully separates critical (Push) from optional (Pull) context but lacks tiered progressive disclosure within each category, leading to "all-or-nothing" context loading that could be more granular.

---

## Current Context Injection Architecture Analysis

### 1. Existing Context Loading Models

The OpenCode system implements two primary context loading patterns as documented in `context-loading-best-practices.md`:

#### Push Model (Critical Context Injection)
**Mechanism**: XML `<context_injection>` blocks in SKILL.md files
**Usage**: 11 core skills implement this pattern
**Typical Load**: 2-4 files per skill (~200-600 lines total)

**Current Implementation**:
```xml
<context_injection>
  <file path=".opencode/context/core/formats/plan-format.md" variable="plan_format" />
  <file path=".opencode/context/core/standards/status-markers.md" variable="status_markers" />
  <file path=".opencode/context/core/workflows/task-breakdown.md" variable="task_breakdown" />
</context_injection>
```

**Skills Using Push Model**:
| Skill | Injected Files | Lines (est.) |
|-------|----------------|--------------|
| skill-planner | 3 | ~400 |
| skill-researcher | 2 | ~300 |
| skill-implementer | 4 | ~600 |
| skill-orchestrator | 2 | ~500 |
| skill-meta | 2 | ~400 |
| skill-learn | 2 | ~300 |
| skill-refresh | 1 | ~200 |
| skill-status-sync | 1 | ~200 |
| skill-git-workflow | 1 | ~200 |
| skill-neovim-research | 2 | ~350 |
| skill-neovim-implementation | 2 | ~350 |

#### Pull Model (On-Demand Context Loading)
**Mechanism**: @-references in agent prompts
**Usage**: Agent specifications reference available context
**Pattern**: Listed in "Context References" or "Always Load" sections

**Example from planner-agent.md**:
```markdown
**Always Load**:
- `@.opencode/context/core/formats/return-metadata-file.md` - Metadata file schema
- `@.opencode/context/core/formats/plan-format.md` - Plan artifact structure

**Load When Creating Plan**:
- `@.opencode/context/core/workflows/task-breakdown.md` - Task decomposition guidelines
```

### 2. Context Window Budget Management

The system demonstrates awareness of context window constraints:

**Orchestrator Budget**: <5% of context window (~10KB) - `orchestrator.md:167`
**Routing Budget**: <10% context window (Stages 1-3) - `routing.md:414`
**Execution Budget**: 90% context window available (Stages 4+) - `routing.md:415`

**Tiered Loading Guidelines from context/README.md**:
- Level 1: <5% context window (~10KB)
- Level 2: 10-20% context window (~20-40KB)  
- Level 3: 60-80% context window (~120-160KB)

---

## Issues: Context Injection in Abundance

### Issue 1: Universal Status-Markers Injection

**Problem**: All 11 skills inject `status-markers.md` regardless of whether they perform state transitions.

**Analysis**:
- Skills like `skill-learn` (tag scanning) and `skill-refresh` (cleanup) don't modify task status
- Status markers are primarily needed for: research -> researching -> researched, planning -> planning -> planned, etc.
- Each injection adds ~100 lines of context that may never be used

**Impact**: 
- Unnecessary ~1,100 lines (11 skills × 100 lines) of redundant context
- Wasted tokens for skills that only read status but never transition it

### Issue 2: Lack of Tiered Loading Within Skills

**Problem**: Skills use "all-or-nothing" context injection rather than progressive disclosure.

**Current Pattern**:
```xml
<context_injection>
  <file path="plan-format.md" variable="plan_format" />
  <file path="status-markers.md" variable="status_markers" />
  <file path="task-breakdown.md" variable="task_breakdown" />
</context_injection>
```

**All loaded at once in Stage 1**, even though:
- `plan-format.md` is only needed during Stage 3 (plan creation)
- `status-markers.md` is needed during Stage 2 (validation) and Stage 4 (postflight)
- `task-breakdown.md` is only needed during Stage 3

**Opportunity**: Implement stage-specific context loading to reduce initial context by ~60%.

### Issue 3: Command Specifications Without Context Injection

**Problem**: Some command specs lack context injection entirely.

**Affected Files**:
- `commands/revise.md` - No `<context_injection>` block
- Routes directly to planner-agent without context
- Relies on agent to load context via @-references

**Inconsistency**: 
- `/plan` uses skill-planner with Push context
- `/revise` bypasses skill wrapper, no context injection
- Results in different context availability for same agent

### Issue 4: Agent Context References Listed but Not Progressive

**Problem**: Agents list many @-references without clear progressive disclosure tiers.

**Example from planner-agent.md**:
```markdown
**Always Load**:
- `@.opencode/context/core/formats/return-metadata-file.md`
- `@.opencode/context/core/formats/plan-format.md`

**Load When Creating Plan**:
- `@.opencode/context/core/workflows/task-breakdown.md`

**Load for Context**:
- `@.opencode/README.md`
- `@.opencode/context/index.md`
```

**Issues**:
1. "Always Load" is too broad - return-metadata-file is only needed when writing metadata
2. No clear distinction between metadata writing vs planning phases
3. "Load for Context" is vague - when exactly should these be loaded?

---

## Industry Best Practices: Progressive Disclosure

### 1. Three-Tier Hierarchical Loading

**Source**: Multiple 2025-2026 publications on AI agent architecture

**Pattern**:
```
Tier 1: Discovery (Navigation/Metadata only)
  - What exists: file catalogs, skill indexes
  - Budget: <10% context window
  
Tier 2: Skills (How to execute)
  - Execution logic: SKILL.md instructions
  - Budget: 10-20% context window
  
Tier 3: Agents (Who does it)
  - Domain expertise: Agent specializations
  - Budget: 60-80% context window
```

**OpenCode Current State**:
- Tier 1: Orchestrator uses routing.md (~200 lines) [GOOD]
- Tier 2: Skills inject 2-4 files [PARTIAL - could be more granular]
- Tier 3: Agents load context on-demand [GOOD]

### 2. Discovery Layer Pattern

**Source**: Anthropic's progressive disclosure guidance, 2025

**Concept**: Separate discovery metadata from execution instructions.

**Implementation**:
```markdown
## Discovery Layer (Always Loaded)
- Skill name and description
- Input/output schema
- Trigger conditions
- 50-100 lines maximum

## Execution Layer (Loaded on Trigger)
- Full SKILL.md content
- Detailed instructions
- Examples and patterns
```

**OpenCode Opportunity**: 
- Current skills inject entire SKILL.md context
- Could implement discovery layer for orchestrator routing
- Would reduce routing context from ~400 lines to ~100 lines per skill

### 3. Stage-Progressive Context Loading

**Source**: "Effective context engineering for AI agents" - Anthropic, Sept 2025

**Pattern**: Load context progressively as stages advance, not all upfront.

**Example**:
```
Stage 1 (Validation): Load only status-checking context
Stage 2 (Preflight): Add header format context
Stage 3 (Execution): Add full format specs and task breakdown
Stage 4 (Postflight): Add state management patterns
```

**OpenCode Opportunity**:
- Currently all context loaded in Stage 1 (LoadContext)
- Could defer format specs until actual creation stage
- Would reduce initial context window by ~40-50%

### 4. Table of Contents Context References

**Source**: Towards AI Academy, 2025

**Pattern**: Instead of loading full context, load a "table of contents" that tells the agent what's available.

**Implementation**:
```markdown
## Available Context (Table of Contents)
- @.opencode/context/core/formats/plan-format.md - Use when creating plans
- @.opencode/context/core/standards/status-markers.md - Use for status transitions
- @.opencode/context/core/workflows/task-breakdown.md - Use for task decomposition

Load these files ONLY when performing their associated operations.
```

**Benefits**:
- Reduces initial context by 60-80%
- Still gives agents awareness of available resources
- Agents fetch detailed context only when needed

---

## Recommended Improvements

### Recommendation 1: Implement Conditional Status-Marker Injection

**Priority**: HIGH  
**Effort**: 1-2 hours

**Change**: Only inject `status-markers.md` for skills that perform state transitions.

**Implementation**:
```xml
<!-- Only for skills that transition status -->
<context_injection>
  <file path=".opencode/context/core/formats/plan-format.md" variable="plan_format" />
  <file path=".opencode/context/core/workflows/task-breakdown.md" variable="task_breakdown" />
  <!-- status-markers.md loaded only for research/plan/implement skills -->
</context_injection>
```

**Affected Skills to Remove status-markers.md**:
- skill-learn (only reads tags, doesn't change status)
- skill-refresh (cleanup operations, status unchanged)
- skill-status-sync (synchronizes existing status, doesn't transition)
- skill-git-workflow (git operations, separate from task status)

**Expected Savings**: ~400 lines of context (4 skills × 100 lines)

### Recommendation 2: Implement Stage-Progressive Loading in Skills

**Priority**: MEDIUM  
**Effort**: 3-4 hours

**Change**: Defer format context loading until actual usage stage.

**Current Pattern (All loaded at start)**:
```xml
<execution>
  <stage id="1" name="LoadContext">
    <action>Read ALL context files</action>
  </stage>
  <stage id="2" name="Preflight">
    <action>Validate (needs only status_markers)</action>
  </stage>
  <stage id="3" name="Delegate">
    <action>Create plan (needs plan_format + task_breakdown)</action>
  </stage>
</execution>
```

**Proposed Pattern (Progressive loading)**:
```xml
<execution>
  <stage id="1" name="LoadMinimalContext">
    <action>Read only status_markers for validation</action>
  </stage>
  <stage id="2" name="Preflight">
    <action>Validate using status_markers</action>
  </stage>
  <stage id="3" name="LoadFormatContext">
    <action>Read plan_format and task_breakdown</action>
  </stage>
  <stage id="4" name="Delegate">
    <action>Create plan with full format context</action>
  </stage>
</execution>
```

**Benefits**:
- Reduces initial context by ~60%
- Faster skill startup for validation-only scenarios
- Context loaded exactly when needed

### Recommendation 3: Add Context Injection to revise.md

**Priority**: HIGH  
**Effort**: 1 hour

**Change**: Ensure /revise command has same context injection as /plan.

**Two Options**:

**Option A - Route through skill-planner**:
```xml
<!-- In revise.md -->
if [ "$plan_exists" = true ]; then
  # Route through skill-planner instead of direct to planner-agent
  skill-planner with revision context
fi
```

**Option B - Add context_injection to revise**:
```xml
<context_injection>
  <file path=".opencode/context/core/formats/plan-format.md" variable="plan_format" />
  <file path=".opencode/context/core/standards/status-markers.md" variable="status_markers" />
</context_injection>
```

**Benefits**:
- Consistent context availability across all planning operations
- Fixes format compliance issue in revised plans

### Recommendation 4: Implement Discovery-Layer Context for Agents

**Priority**: MEDIUM  
**Effort**: 2-3 hours

**Change**: Provide agents with "table of contents" of available context rather than listing everything as "Always Load".

**Current Pattern**:
```markdown
**Always Load**:
- `@.opencode/context/core/formats/return-metadata-file.md`
- `@.opencode/context/core/formats/plan-format.md`
```

**Proposed Pattern**:
```markdown
## Context Discovery Index

**Available for Planning Operations**:
- `@.opencode/context/core/formats/plan-format.md` - Plan structure and format standards
- `@.opencode/context/core/workflows/task-breakdown.md` - Task decomposition guidelines
- Load these when creating or revising plans

**Available for Metadata Operations**:
- `@.opencode/context/core/formats/return-metadata-file.md` - Metadata file schema
- Load this when writing return metadata files

**Load based on your current operation, not all at once.**
```

**Benefits**:
- Agents understand what's available without context bloat
- Progressive disclosure based on actual operation
- Clear guidance on when to load each context file

### Recommendation 5: Add Context Budget Enforcement

**Priority**: LOW  
**Effort**: 4-6 hours

**Change**: Implement context size validation in skill-structure.md standards.

**Implementation**:
```markdown
### Context Budget Standards

**Maximum Injected Context per Skill**: 800 lines
- Rationale: Keeps skill context under ~20% of typical context window
- Exceeding this requires architecture review

**Status**: guideline (not enforced by tooling)
```

**Benefits**:
- Prevents gradual context bloat
- Provides clear guidance for skill developers
- Maintains system performance over time

---

## Implementation Priority Matrix

| Recommendation | Priority | Effort | Impact | Risk |
|----------------|----------|--------|--------|------|
| Conditional status-marker injection | HIGH | 1-2 hrs | High savings (400 lines) | Low |
| Add context injection to revise.md | HIGH | 1 hr | Fixes compliance bug | Low |
| Discovery-layer context pattern | MEDIUM | 2-3 hrs | Better progressive disclosure | Low |
| Stage-progressive loading | MEDIUM | 3-4 hrs | 60% initial context reduction | Medium |
| Context budget enforcement | LOW | 4-6 hrs | Long-term bloat prevention | Low |

**Recommended Implementation Order**:
1. **Phase 1**: Fix revise.md context injection (fixes current bug)
2. **Phase 2**: Remove unnecessary status-marker injections (immediate savings)
3. **Phase 3**: Implement discovery-layer pattern (better architecture)
4. **Phase 4**: Stage-progressive loading (advanced optimization)
5. **Phase 5**: Budget enforcement (maintenance)

---

## Risks & Considerations

### Risk 1: Over-Optimization Breaking Reliability

**Concern**: Too granular context loading could cause agents to miss critical context.

**Mitigation**:
- Maintain Push model for truly critical context
- Add explicit instructions: "Load X before doing Y"
- Test thoroughly after each optimization

### Risk 2: Inconsistent Context Between Skills

**Concern**: Different skills loading different context could create inconsistencies.

**Mitigation**:
- Document which context is critical vs optional per skill type
- Maintain shared "critical context" list
- Regular audits of context injection patterns

### Risk 3: Increased Complexity

**Concern**: Progressive disclosure adds complexity to skill definitions.

**Mitigation**:
- Start with simple improvements (remove unnecessary injections)
- Only implement stage-progressive loading for most-used skills
- Document patterns clearly with examples

### Risk 4: Agent Confusion

**Concern**: Agents might not know when to load which context.

**Mitigation**:
- Discovery-layer pattern gives them awareness
- Clear stage-by-stage instructions
- Fallback: load all context if agent explicitly requests it

---

## Summary: Progressive Disclosure Principles for OpenCode

Based on this research, the OpenCode system should adopt these principles:

### 1. Surgical Precision Over Abundance
**Current**: "Inject all potentially useful context"
**Target**: "Inject only context needed for current operation"

### 2. Tiered Progressive Loading
**Current**: All context loaded at skill start
**Target**: Discovery -> Validation -> Execution -> Postflight (staged loading)

### 3. Consistent Context Availability
**Current**: /plan has context, /revise doesn't
**Target**: All planning operations have consistent format context

### 4. Discovery-Aware Agents
**Current**: Agents told what to always load
**Target**: Agents know what's available and load based on operation

### 5. Measured Context Budgets
**Current**: Guidelines without enforcement
**Target**: Clear budgets and occasional audits

---

## Next Steps

1. **Immediate**: Fix revise.md context injection (OC_137 Phase 5)
2. **Short-term**: Remove status-markers.md from non-transition skills
3. **Medium-term**: Implement discovery-layer pattern in agent specs
4. **Long-term**: Consider stage-progressive loading for high-volume skills

**Integration with Current OC_137 Plan**:
- Phase 4 (planner-agent.md enhancements) should include discovery-layer pattern
- Phase 5 (revise.md context injection) is now HIGHER priority
- Consider adding Phase 7 for status-marker optimization

---

## References

**OpenCode Internal**:
- `.opencode/docs/guides/context-loading-best-practices.md` - Push vs Pull models
- `.opencode/context/core/orchestration/routing.md` - Context budgets
- `.opencode/context/README.md` - Tiered loading guidelines

**External Best Practices**:
- "Effective context engineering for AI agents" - Anthropic, Sept 2025
- "Progressive Disclosure in AI Agent Skill Design" - Towards AI, 2025
- "Hierarchical Context Loading" - Chris Groves, 2025
- "Progressive Disclosure Is Quietly Reshaping How AI Agents Are Built" - Medium, Jan 2026

**Related OC_137 Research**:
- `research-001.md` - Format compliance investigation
- `research-002.md` - Root cause analysis (embedded templates)
- `implementation-001.md` - Current implementation plan

---

**End of Report**
