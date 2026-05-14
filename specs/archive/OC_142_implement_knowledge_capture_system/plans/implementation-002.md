# Implementation Plan: Task #142

- **Task**: 142 - Implement Knowledge Capture System
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: OC_143 (fix metadata delegation) - MUST complete first
- **Research Inputs**: specs/OC_142_implement_knowledge_capture_system/reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: .opencode/context/core/formats/plan-format.md, .opencode/context/core/standards/status-markers.md, .opencode/context/core/standards/documentation-standards.md, .opencode/context/core/standards/task-management.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan implements a comprehensive knowledge capture system with three integrated features: (1) renaming /learn to /fix for clearer semantics, (2) adding task mode to /remember for automated artifact review with interactive classification, and (3) enhancing /todo with automatic CHANGE_LOG.md updates and memory harvest suggestions. The implementation follows a dependency-first approach, waiting for OC_143 completion before proceeding with core feature development.

### Research Integration

Research findings indicate NONE of the three planned enhancements are implemented:
- /learn still exists as learn.md, needs rename to fix.md
- /remember has no task mode capability, no --task parsing
- /todo has EMPTY skill directory, needs full extraction
- No CHANGE_LOG.md exists anywhere
- Memory vault exists but is empty

Critical dependency: OC_143 must complete first to avoid conflicts with metadata delegation fixes.

Recommended order: Wait for OC_143 -> Create skill-todo -> Rename /learn -> Add /remember task mode -> Integration testing.

## Goals & Non-Goals

**Goals**:
- Rename /learn command to /fix with updated semantics
- Add task mode to /remember with artifact review and 5-category classification
- Create skill-todo infrastructure with full logic extraction from todo.md
- Implement automatic CHANGE_LOG.md updates in todo.md
- Add memory harvest suggestions to /todo completion flow
- Maintain backward compatibility where feasible

**Non-Goals**:
- Rewriting core metadata delegation (handled by OC_143)
- Creating new memory vault structure (use existing)
- Changing /remember text or file input modes
- Adding non-knowledge-capture features to /todo
- Implementing automatic memory harvesting (only suggestions)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| OC_143 not completed before start | High | Medium | Phase 1 blocks until OC_143 is done; verify status before proceeding |
| Breaking changes to existing workflows | Medium | Low | Hard rename with clear migration path; update all internal references |
| /remember task mode complexity | Medium | Medium | Start with simple file listing, add classification incrementally |
| skill-todo extraction scope creep | Medium | Medium | Strict boundary: only todo.md logic, no other command changes |
| Memory vault schema conflicts | Low | Low | Use existing vault structure, only add new memory type for task insights |

## Implementation Phases

### Phase 1: OC_143 Dependency Verification [NOT STARTED]

**Goal**: Ensure OC_143 is completed before proceeding

**Tasks**:
- [ ] Check OC_143 status in specs/state.json or via /task command
- [ ] Verify metadata delegation fixes are merged
- [ ] Review OC_143 changes to understand any impact on this task
- [ ] If OC_143 incomplete: document block and wait
- [ ] If OC_143 complete: proceed to Phase 2

**Timing**: 0.5 hours (verification only, may extend if waiting)

**Rollback**: None needed (no changes made)

### Phase 2: Create skill-todo Infrastructure [NOT STARTED]

**Goal**: Extract todo.md logic into dedicated skill with CHANGE_LOG.md support

**Tasks**:
- [ ] Read .opencode/commands/todo.md (278 lines) to understand current embedded logic
- [ ] Analyze todo.md workflow and identify delegation points
- [ ] Create .opencode/skills/skill-todo/SKILL.md following skill-template.md
- [ ] Implement todo-agent subagent following research-agent pattern
- [ ] Add CHANGE_LOG.md management functions:
  - [ ] Create specs/CHANGE_LOG.md if not exists
  - [ ] Add entry format: date, task, type, description
  - [ ] Implement auto-append on task status changes
- [ ] Add memory harvest suggestion logic:
  - [ ] Scan completed task artifacts for insights
  - [ ] Suggest memory creation based on key learnings
  - [ ] Interactive prompt: "Create memory from this insight?"
- [ ] Update todo.md to delegate to skill-todo instead of embedded logic
- [ ] Test basic todo operations work via new skill

**Timing**: 5 hours

**Rollback**:
1. Keep original todo.md backup
2. If skill fails, restore embedded logic in todo.md
3. Remove skill-todo directory if extraction fails

### Phase 3: Rename /learn to /fix [NOT STARTED]

**Goal**: Rename command and skill from /learn to /fix with updated semantics

**Tasks**:
- [ ] Rename .opencode/commands/learn.md to fix.md
- [ ] Update fix.md command specification:
  - [ ] Change command name from /learn to /fix
  - [ ] Update description to emphasize "fix/correct" semantics
  - [ ] Modify examples to show fixing patterns
- [ ] Rename .opencode/skills/skill-learn/ to skill-fix/
- [ ] Update skill-fix/SKILL.md:
  - [ ] Change all /learn references to /fix
  - [ ] Update agent metadata and delegation
  - [ ] Modify examples for fix context
- [ ] Update all internal references:
  - [ ] Search for "learn" in commands directory, update to "fix"
  - [ ] Search for "learn" in skills directory, update to "fix"
  - [ ] Check for any hardcoded paths to skill-learn
- [ ] Test /fix command works correctly
- [ ] Verify no broken references remain

**Timing**: 2.5 hours

**Rollback**:
1. Rename directories back: fix.md -> learn.md, skill-fix -> skill-learn
2. Restore original file contents from git or backup
3. Revert any reference updates

### Phase 4: Add Task Mode to /remember [NOT STARTED]

**Goal**: Implement --task OC_N mode for artifact review with interactive classification

**Tasks**:
- [ ] Read .opencode/commands/remember.md (95 lines) to understand current modes
- [ ] Read .opencode/skills/skill-remember/SKILL.md (208 lines) for skill structure
- [ ] Design --task argument parsing in remember.md:
  - [ ] Add --task OC_N to command specification
  - [ ] Document task mode behavior
- [ ] Implement task directory parsing in skill-remember:
  - [ ] Parse specs/OC_{N}_{SLUG}/ structure
  - [ ] Identify artifact files (reports/, plans/, code/, etc.)
  - [ ] Generate file listing for review
- [ ] Implement interactive classification workflow:
  - [ ] Display artifact list with numbers
  - [ ] Allow user to select file(s) to review
  - [ ] Show file content in chunks for review
  - [ ] Present 5 classification categories:
    1. [TECHNIQUE] - Reusable method or approach
    2. [PATTERN] - Design or implementation pattern
    3. [CONFIG] - Configuration or setup knowledge
    4. [WORKFLOW] - Process or procedure
    5. [INSIGHT] - Key learning or understanding
    6. [SKIP] - Not valuable for memory
  - [ ] Capture user classification selection
- [ ] Create memory from classified content:
  - [ ] Extract key insight from artifact
  - [ ] Format memory with classification tag
  - [ ] Save to memory vault (vault/memories/)
- [ ] Update skill-remember/SKILL.md with task mode documentation
- [ ] Test task mode with actual task directory

**Timing**: 5 hours

**Rollback**:
1. Revert remember.md to original (remove --task option)
2. Restore skill-remember/SKILL.md to original
3. Remove any test memories created during development

### Phase 5: Integration & Validation [NOT STARTED]

**Goal**: Test all three features work together and fix any issues

**Tasks**:
- [ ] End-to-end test: Create test task via /todo
- [ ] Verify CHANGE_LOG.md auto-updates on task completion
- [ ] Test /fix command still works after rename
- [ ] Test /remember task mode with test task artifacts
- [ ] Verify memory harvest suggestions appear in /todo completion
- [ ] Test edge cases:
  - [ ] /remember --task with non-existent task number
  - [ ] /todo with no artifacts to harvest
  - [ ] /fix with various input types
- [ ] Cross-feature integration test:
  - [ ] Create task -> Add memory via /remember -> Complete task -> Verify CHANGE_LOG -> Check harvest suggestions
- [ ] Fix any integration bugs found
- [ ] Performance check: Ensure no significant slowdown

**Timing**: 2.5 hours

**Rollback**:
1. Restore all files to pre-integration state
2. Re-run individual phase rollbacks if needed
3. Document which phase caused integration issue

### Phase 6: Documentation & Examples [NOT STARTED]

**Goal**: Update all documentation and create usage examples

**Tasks**:
- [ ] Update .opencode/commands/README.md:
  - [ ] Change /learn to /fix in command list
  - [ ] Add /remember task mode description
  - [ ] Document /todo CHANGE_LOG feature
- [ ] Update .opencode/skills/README.md:
  - [ ] Add skill-todo entry
  - [ ] Update skill-learn to skill-fix
- [ ] Create example usage for /fix:
  - [ ] Example 1: Fixing a common configuration error
  - [ ] Example 2: Documenting a workaround
- [ ] Create example usage for /remember task mode:
  - [ ] Example: Reviewing a research report and creating memories
- [ ] Update CHANGE_LOG.md with this implementation entry
- [ ] Verify all internal links work
- [ ] Final documentation review for consistency

**Timing**: 0.5 hours

**Rollback**:
1. Revert documentation files to original state
2. Re-run if issues found

## Testing & Validation

- [ ] All /todo operations work via skill-todo
- [ ] CHANGE_LOG.md auto-updates on task status changes
- [ ] Memory harvest suggestions appear in /todo completion flow
- [ ] /fix command responds correctly (renamed from /learn)
- [ ] All /learn references updated to /fix
- [ ] /remember --task OC_N parses task directory correctly
- [ ] Artifact review shows all files in task directory
- [ ] Classification taxonomy presents 5 categories + skip
- [ ] Memories created with correct classification tags
- [ ] No broken internal references
- [ ] All examples work as documented
- [ ] Integration test passes (create -> remember -> complete -> verify)

## Artifacts & Outputs

- `.opencode/commands/fix.md` (renamed from learn.md)
- `.opencode/skills/skill-fix/SKILL.md` (renamed and updated)
- `.opencode/skills/skill-todo/SKILL.md` (new)
- `.opencode/skills/skill-todo/todo-agent.lua` (new subagent)
- `.opencode/commands/remember.md` (updated with --task)
- `.opencode/skills/skill-remember/SKILL.md` (updated with task mode)
- `specs/CHANGE_LOG.md` (new)
- `.opencode/commands/todo.md` (updated to delegate to skill)
- Updated README files in commands/ and skills/
- Test memories in vault/memories/

## Rollback/Contingency

**Full Rollback Procedure**:
1. Use git to revert all changes: `git checkout -- .opencode/commands/learn.md .opencode/skills/skill-learn/`
2. Remove new files: `rm -rf .opencode/skills/skill-todo/ .opencode/commands/fix.md specs/CHANGE_LOG.md`
3. Restore todo.md embedded logic if needed
4. Verify system returns to original state
5. Document rollback reason and re-plan

**Partial Rollback Options**:
- Phase 2 only: Restore embedded todo.md logic, remove skill-todo
- Phase 3 only: Rename back to /learn, restore skill-learn
- Phase 4 only: Remove --task from remember.md, revert skill-remember

**Contingency Plans**:
- If OC_143 delayed >2 days: Consider starting Phase 2-3 in parallel with coordination
- If /remember task mode too complex: Split into two phases (basic review first, classification second)
- If CHANGE_LOG.md location disputed: Discuss with team, can move to alternate location
- If skill-todo extraction breaks: Maintain embedded logic as fallback

## Implementation Notes

**Design Decisions Applied**:
- CHANGE_LOG.md location: specs/CHANGE_LOG.md (Option A from research)
- Task mode syntax: --task OC_N (Option A from research)
- Classification taxonomy: 5 categories + skip (research recommendation)
- Backward compatibility: Hard rename (Option A from research)
- skill-todo scope: Full extraction (Option A from research)

**Agent Guidelines**:
- Each phase is self-contained and can be resumed if interrupted
- Test after EACH phase before proceeding
- Document any deviations from plan in task comments
- If stuck on a phase >2 hours, escalate to human
- Maintain git commits between phases for rollback safety

**Success Criteria**:
- All three features functional and integrated
- No regression in existing functionality
- Documentation updated and accurate
- CHANGE_LOG.md contains this implementation entry
- At least one successful end-to-end test completed
