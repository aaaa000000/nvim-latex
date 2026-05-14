# Research Report: Task #136 (Follow-up)

**Task**: OC_136 - Design and implement `/remember` command for intelligent memory management  
**Started**: 2026-03-05T23:45:00Z  
**Completed**: 2026-03-05T23:55:00Z  
**Effort**: 1 hour  
**Priority**: High  
**Focus**: Impact of OC_135 revert on system architecture and /remember command design  
**Dependencies**: OC_135 (reverted)  
**Sources/Inputs**: 
- Git commit history (revert 231abbb7)
- Current .opencode/ system state
- OC_135 implementation summaries and plans
- Comparison of pre-revert vs post-revert file states
**Artifacts**: 
- `specs/OC_136_design_and_implement_remember_command_for_intelligent_memory_management/reports/research-002.md`
**Standards**: report-format.md, command-structure.md, skill-structure.md

---

## Executive Summary

- **Task 135 completely reverted**: All .opencode/ changes from OC_135 removed, leaving the agent system in a pre-OC_135 state but with broken references
- **Critical finding**: Skills (skill-researcher, skill-planner, skill-implementer) still reference non-existent agents (general-research-agent, planner-agent) creating a broken delegation chain
- **System is now hybrid/mixed**: Commands are implementation guides, some skills are direct execution (skill-learn), others attempt broken delegation
- **Impact on OC_136**: Must design /remember to work with current broken state - direct execution pattern (like skill-learn) is the only viable approach
- **Recommendation**: Implement skill-remember as direct execution skill without agent delegation; create remember command as detailed implementation guide following research.md pattern

---

## Context & Scope

### User's Specific Focus

The user explicitly stated: "I just reverted task 135 which caused problems for my agent system. Investigate what might need to change accordingly given the way my .opencode/ agent system is now organized."

This follow-up research specifically investigates:
1. What was in the OC_135 revert
2. What "problems" the revert caused
3. How the current system is organized post-revert
4. What implications this has for the /remember command design

### Scope

**In Scope**:
- Analysis of revert commit 231abbb7
- Comparison of pre-revert vs post-revert system state
- Identification of broken references and inconsistencies
- Recommendations for /remember design given current state

**Out of Scope**:
- Proposing fixes for the broken system (user explicitly reverted, suggesting intentional choice)
- Re-implementing OC_135 features
- General memory management research (covered in research-001.md)

---

## Findings

### 1. What Was Reverted in OC_135

**Commit 231abbb7** ("Revert task OC_135: Remove command routing infrastructure (.opencode changes only)") removed:

**Files Deleted**:
- `.opencode/agent/command-router.md` (225 lines) - Central routing agent
- `.opencode/docs/guides/command-routing.md` (299 lines) - Routing documentation
- `.opencode/skills/README.md` (267 lines) - Skills overview
- `.opencode/skills/skill-errors/SKILL.md` (117 lines)
- `.opencode/skills/skill-reviewer/SKILL.md` (132 lines)
- `.opencode/skills/skill-revisor/SKILL.md` (140 lines)
- `.opencode/skills/skill-todo/SKILL.md` (120 lines)

**Files Reverted to Previous State**:
- `.opencode/commands/README.md` - Lost routing specification content
- `.opencode/commands/errors.md` - Lost routing spec, regained implementation guide
- `.opencode/commands/implement.md` - Lost routing spec, regained implementation guide
- `.opencode/commands/learn.md` - Lost routing spec, regained hybrid state
- `.opencode/commands/plan.md` - Lost routing spec, regained implementation guide
- `.opencode/commands/refresh.md` - Lost routing spec, regained implementation guide
- `.opencode/commands/research.md` - Lost routing spec, regained implementation guide
- `.opencode/commands/review.md` - Lost routing spec, regained implementation guide
- `.opencode/commands/revise.md` - Lost routing spec, regained implementation guide
- `.opencode/commands/todo.md` - Lost routing spec, regained implementation guide
- `.opencode/skills/skill-learn/SKILL.md` - Lost thin wrapper pattern, regained direct execution
- `.opencode/skills/skill-refresh/SKILL.md` - Lost thin wrapper pattern, regained direct execution

**Preserved**:
- `specs/` directory intentionally kept (all research, plans, summaries from OC_135)

### 2. Current System State (Post-Revert)

#### Commands: Implementation Guides (Not Routing Specs)

Current commands contain detailed step-by-step instructions for what to do. Example from `/research.md`:

```markdown
## Steps

### 1. Look up task
Strip `OC_` prefix, find task in `specs/state.json`:
```bash
jq --arg n "N" '.active_projects[] | select(.project_number == ($n | tonumber))' specs/state.json
```
```

This shows commands are **implementation guides** that tell the AI exactly what steps to execute.

#### Skills: Broken Hybrid State

**Direct Execution Skills** (working):
- `skill-learn` - No `context: fork`, no `agent:` field. Direct execution.
- `skill-refresh` - Direct execution pattern

**Broken Delegation Skills** (non-functional):
- `skill-researcher` - Has `context: fork`, `agent: general-research-agent`
- `skill-planner` - Has `context: fork`, `agent: planner-agent`
- `skill-implementer` - Has `context: fork`, references agents

**Problem**: The agents these skills reference do NOT exist:
```bash
$ ls -la .opencode/agents/
ls: cannot access '.opencode/agents/': No such file or directory
```

**Impact**: When these skills are invoked, they will attempt to delegate to non-existent agents, causing failures.

#### Missing Skills (Created in OC_135, Removed in Revert)

The following skills no longer exist:
- skill-errors
- skill-reviewer
- skill-revisor
- skill-todo

These were created as thin wrapper skills with fork context. Their removal breaks any commands that reference them (if any do).

### 3. The "Problems" Caused by Revert

#### Problem 1: Broken Delegation Chain

**Symptom**: Skills reference agents that don't exist.

**Evidence**:
```bash
$ grep "agent:" .opencode/skills/*/SKILL.md
skill-researcher/SKILL.md:agent: general-research-agent
skill-planner/SKILL.md:agent: planner-agent
skill-implementer/SKILL.md:agent: general-implementation-agent
```

**Impact**: Any workflow using /research, /plan, or /implement will fail when trying to delegate to non-existent agents.

#### Problem 2: Inconsistent Architecture

**Symptom**: Mixed patterns without clear guidance.

- Commands are implementation guides (direct AI execution)
- Some skills are direct execution
- Some skills attempt broken delegation
- No command router to coordinate

**Impact**: Unclear which pattern to use for new features like /remember.

#### Problem 3: Missing Documentation

**Symptom**: README files removed.

Removed:
- `.opencode/commands/README.md` (overview lost)
- `.opencode/skills/README.md` (patterns lost)
- `.opencode/docs/guides/command-routing.md` (routing guide lost)

**Impact**: No authoritative documentation on how the system should work.

### 4. What Pattern Works (Current Reality)

#### Verified Working Pattern: skill-learn

**Structure**:
```yaml
---
name: skill-learn
description: Scan files for FIX:/NOTE:/TODO: tags and create tasks.
allowed-tools: Task, Bash, Edit, Read, Write
---

# Learn Skill

Direct execution skill for scanning tags and creating tasks.

<context>
  <system_context>OpenCode tag scanning and task creation.</system_context>
  <task_context>Scan codebase tags and create tasks based on selections.</task_context>
</context>

<context_injection>
  <file path="specs/TODO.md" variable="todo_file" />
  <file path="specs/state.json" variable="state_file" />
</context_injection>

<role>Direct execution skill for tag discovery.</role>

<task>Scan FIX/NOTE/TODO tags and create tasks.</task>

<execution>
  <stage id="1" name="LoadContext">
    <action>Load {todo_file} and {state_file} for task management</action>
  </stage>
  <stage id="2" name="ScanTags">
    <action>Scan for FIX:/NOTE:/TODO: tags across codebase</action>
  </stage>
  <stage id="3" name="InteractiveSelection">
    <action>Present findings and let user select which to convert to tasks</action>
  </stage>
  <stage id="4" name="CreateTasks">
    <action>Create tasks in {todo_file} and {state_file} for selected selected tags</action>
  </stage>
</execution>
```

**Key Characteristics**:
1. **No `context: fork`** - Direct execution, not subagent delegation
2. **No `agent:` field** - Skill does the work itself
3. **`allowed-tools` list** - Explicit tool permissions
4. **Context injection** - Loads required files via `<context_injection>`
5. **Execution stages** - Defined workflow stages
6. **Direct execution** - Skill implements logic, not just delegates

#### Verified Working Pattern: /research Command

**Structure**:
```markdown
---
description: Research a task and create a research report
---

Research the given task and write a research report. Do NOT implement anything.

**Input**: $ARGUMENTS

---

## Parse Input

- First token: task number — accepts `OC_N` or `N` (strip `OC_` prefix to get integer N)
- Remaining tokens: optional focus prompt
...

## Steps

### 1. Look up task
...

### 2. Validate status
...

### 3. Update status
...
```

**Key Characteristics**:
1. **Implementation guide** - Detailed step-by-step instructions
2. **Direct AI execution** - AI follows the guide to execute
3. **State management** - Instructions for updating state.json, TODO.md
4. **Tool usage** - Specific tool calls (jq, Edit, Write, etc.)
5. **No delegation** - No Skill() or Task() calls to subagents

### 5. Implications for OC_136 (/remember)

#### What Research-001.md Assumed (Now Invalid)

The initial research assumed the OC_135 architecture:
- Commands as routing specs (delegate to skills)
- Skills as thin wrappers (fork context, delegate to agents)
- Three-layer architecture (Command → Skill → Agent)

**This architecture was reverted and no longer exists.**

#### What Actually Exists (Current Reality)

- Commands as implementation guides (direct AI execution)
- Skills as direct execution (skill-learn pattern)
- Some broken skills that reference missing agents
- No agent layer

#### Required Design Changes for /remember

**Original Plan (Research-001)**:
```
User Input
    |
    v
Command: remember.md (routing spec)
    |
    v
Skill: skill-remember/SKILL.md (thin wrapper)
    |
    v
Agent: remember-agent.md (core logic)
```

**Required New Plan**:
```
User Input
    |
    v
Command: remember.md (implementation guide)
    |
    v
Skill: skill-remember/SKILL.md (direct execution)
    |
    v
[Skill implements all logic directly - no agent layer]
```

**Specific Changes Required**:

1. **Command File**:
   - Make it an implementation guide (like /research.md)
   - Detailed step-by-step instructions
   - Direct tool usage (no Skill() delegation)
   - State management instructions

2. **Skill File**:
   - Direct execution (like skill-learn)
   - No `context: fork`
   - No `agent:` field
   - Include all logic in skill itself
   - `allowed-tools` list for permissions

3. **No Agent File**:
   - Do NOT create .opencode/agents/remember-agent.md
   - Agent layer doesn't exist in current system
   - All logic goes in skill

---

## Decisions

### Decision 1: Follow skill-learn Pattern (Not OC_135 Pattern)

**Decision**: Implement /remember following the skill-learn direct execution pattern, NOT the thin wrapper + agent delegation pattern from OC_135.

**Rationale**:
- skill-learn is proven working in current system
- OC_135 architecture was reverted and is non-functional
- Direct execution is simpler and more reliable
- No broken references or missing dependencies

### Decision 2: Command as Implementation Guide

**Decision**: Create `.opencode/commands/remember.md` as a detailed implementation guide (like /research.md), not as a routing specification.

**Rationale**:
- Current commands are implementation guides
- User's system expects direct AI execution
- Implementation guides are more explicit and debuggable
- No delegation layer to break

### Decision 3: No Agent File

**Decision**: Do NOT create `.opencode/agents/remember-agent.md`.

**Rationale**:
- Agents directory doesn't exist in current system
- Skills attempt to reference non-existent agents
- All logic should be in skill itself
- Simpler architecture with fewer files

### Decision 4: Single-File Skill Architecture

**Decision**: All /remember logic goes in `.opencode/skills/skill-remember/SKILL.md` as direct execution.

**Rationale**:
- Avoids the broken delegation chain
- Follows working skill-learn pattern
- Simpler to understand and maintain
- No risk of missing agent dependencies

---

## Recommendations

### 1. Architecture for /remember (Priority: Critical)

**Do NOT implement from research-001.md's recommendations.** They assumed the reverted OC_135 architecture.

**Implement this instead**:

```
.opencode/
├── commands/
│   └── remember.md           # Implementation guide (detailed steps)
└── skills/
    └── skill-remember/
        └── SKILL.md          # Direct execution (all logic here)
```

**No agents/ directory.** No agent files. Direct execution only.

### 2. Command Structure (Priority: High)

`.opencode/commands/remember.md` should follow `/research.md` pattern:

```markdown
---
description: Intelligent memory management with interactive approval
---

Research the given task and write a research report. Do NOT implement anything.

**Input**: $ARGUMENTS

---

## Parse Input

- First token: prompt or file path
- Validate: text string or existing file path
- If file: validate exists and is readable

---

## Steps

### 1. Input Analysis
...

### 2. Content Extraction
...

### 3. Memory Comparison
...

### 4. Research Decision
...

### 5. Generate Proposals
...

### 6. Interactive Approval
...

### 7. Apply Updates
...
```

### 3. Skill Structure (Priority: High)

`.opencode/skills/skill-remember/SKILL.md` should follow `skill-learn` pattern:

```yaml
---
name: skill-remember
description: Intelligent memory management with analysis and interactive approval
allowed-tools: Task, Bash, Edit, Read, Write, Grep, Glob
---

# Remember Skill

Direct execution skill for memory management.

<context>
  <system_context>OpenCode memory management.</system_context>
  <task_context>Analyze input, compare with memory, propose additions.</task_context>
</context>

<context_injection>
  <file path=".opencode/context/memory/index.md" variable="memory_index" />
</context_injection>

<role>Direct execution skill for memory management.</role>

<task>Analyze input, compare with existing memory, propose additions.</task>

<execution>
  <stage id="1" name="AnalyzeInput">
    <action>Parse and analyze user input (text or file)</action>
  </stage>
  <stage id="2" name="ExtractContent">
    <action>Extract key concepts, patterns, and information</action>
  </stage>
  <stage id="3" name="CompareMemory">
    <action>Compare against existing memory index</action>
  </stage>
  <stage id="4" name="GenerateProposals">
    <action>Generate proposed memory additions</action>
  </stage>
  <stage id="5" name="InteractiveApproval">
    <action>Present proposals via AskUserQuestion multiSelect</action>
  </stage>
  <stage id="6" name="ApplyUpdates">
    <action>Update memory files for approved items</action>
  </stage>
</execution>
```

**Critical differences from research-001**:
- No `context: fork`
- No `agent:` field
- No delegation to subagents
- Direct execution only

### 4. Avoid Broken Patterns (Priority: High)

**Do NOT use**:
- ❌ `context: fork` in skills
- ❌ `agent:` field in skills
- ❌ References to `.opencode/agents/*.md`
- ❌ Skill() or Task() delegation calls
- ❌ Three-layer architecture assumptions

**DO use**:
- ✅ Direct skill execution (skill-learn pattern)
- ✅ Implementation guide commands (research.md pattern)
- ✅ All logic in skill file
- ✅ Explicit tool permissions
- ✅ Context injection for required files

### 5. Testing Strategy (Priority: Medium)

Test /remember with simple inputs before complex scenarios:

**Phase 1**: Text prompt input
**Phase 2**: Single file input
**Phase 3**: Multiple file inputs
**Phase 4**: Research augmentation

Verify each phase works before proceeding.

---

## Risks & Mitigations

### Risk 1: Inconsistent with Other Commands

**Risk**: /remember uses different pattern than /research, /plan which have broken delegation.

**Mitigation**:
- Document clearly that /remember uses WORKING pattern
- Note that /research, /plan may need similar conversion
- User chose to revert OC_135, suggesting preference for simpler patterns

### Risk 2: Future Re-implementation of OC_135

**Risk**: If OC-135 is re-implemented later, /remember will need conversion.

**Mitigation**:
- Design skill-remember with clear stage separation
- Document architecture decision in skill file
- Conversion to thin wrapper would be straightforward if needed

### Risk 3: Skill File Complexity

**Risk**: All logic in single skill file becomes unwieldy.

**Mitigation**:
- Keep stages clear and focused
- Use context injection for complex reference material
- Modularize within skill using helper functions (if applicable)

---

## Appendix

### A. Comparison: OC_135 Architecture vs Current State

| Component | OC_135 (Reverted) | Current State | Working? |
|-----------|-------------------|---------------|----------|
| Commands | Routing specs | Implementation guides | ✅ Working |
| Skills | Thin wrappers (fork context) | Mixed: direct + broken delegation | ⚠️ Partial |
| Agents | Full agent layer | No agents directory | ❌ Broken refs |
| Router | command-router.md | Does not exist | ❌ Missing |
| Documentation | README + routing guide | Minimal | ⚠️ Limited |

### B. Working Skills (Current)

**Verified working**:
- `skill-learn` - Direct execution, tag scanning
- `skill-refresh` - Direct execution, cleanup tasks

**Broken (reference missing agents)**:
- `skill-researcher` - References general-research-agent (doesn't exist)
- `skill-planner` - References planner-agent (doesn't exist)
- `skill-implementer` - References general-implementation-agent (doesn't exist)

### C. Recommended File Structure for /remember

```
.opencode/
├── commands/
│   └── remember.md              # Implementation guide (~200 lines)
│
└── skills/
    └── skill-remember/
        └── SKILL.md             # Direct execution (~150 lines)

# NO agents/ directory
# NO command-router.md
# NO delegation to subagents
```

### D. Related Documentation

- research-001.md: General memory management research (architecture patterns, best practices)
- This report (research-002.md): System state analysis and adjusted recommendations
- OC_135 plans/summaries: What was implemented then reverted

---

## Next Steps

Run `/plan OC_136` to create an implementation plan that:
1. Uses direct execution pattern (skill-learn style)
2. Creates implementation guide command (research.md style)
3. Does NOT create agent files
4. Avoids all OC_135 patterns that were reverted

**Important**: Review the plan carefully to ensure it doesn't accidentally reintroduce OC_135 patterns (context: fork, agent delegation, etc.).
