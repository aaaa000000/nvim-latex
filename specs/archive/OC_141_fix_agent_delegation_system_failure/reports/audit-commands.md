# Command Specification Audit Report

**Task**: OC_141 - Fix Agent Delegation System Failure  
**Phase**: 1 - Audit Command Specifications  
**Date**: 2026-03-06  
**Status**: COMPLETED

---

## Executive Summary

**ROOT CAUSE IDENTIFIED**: The system architecture involves three layers: Commands → Skills → Agents. The skills ARE correctly designed to use Task tool with subagent_type to invoke agents. However, when workflow commands run, skills are being displayed instead of executed - the Task tool invocation in the skill's Delegate stage never occurs.

## System Architecture (Correct Design)

Command (/plan N)
  ↓ (calls skill tool)
Skill (skill-planner)
  ├── Stage 1: Load Context
  ├── Stage 2: Preflight (validate, display header, update status)
  ├── Stage 3: Delegate → Task tool with subagent_type="planner-agent" [NOT HAPPENING]
  └── Stage 4: Postflight (update state, commit)
  ↓
Agent (planner-agent)
  └── Creates plan file

## Command Specifications Analyzed

| Command | File | Skill Referenced | Status |
|---------|------|------------------|--------|
| /plan | plan.md | skill-planner | Not executing |
| /implement | implement.md | skill-implementer | Not executing |
| /research | research.md | skill-researcher | Not executing |
| /revise | revise.md | skill-planner | Not executing |
| /meta | meta.md | skill-meta | Not executing |
| /learn | learn.md | skill-learn | Not executing |
| /refresh | refresh.md | skill-refresh | Not executing |
| /remember | remember.md | skill-remember | Not executing |
| /review | review.md | skill-reviewer | Not executing |
| /status | status.md | skill-status-sync | Not executing |
| /todo | todo.md | (unknown) | Not executing |
| /task | task.md | skill-orchestrator | Not executing |

Pattern: All commands describe skill invocation but don't explicitly show the tool call syntax.

## Skill Specifications Analyzed

| Skill | Uses Task Tool | subagent_type | Status |
|-------|---------------|---------------|--------|
| skill-planner | Yes | planner-agent | Correct design |
| skill-implementer | Yes | general-implementation-agent | Correct design |
| skill-researcher | Yes | general-research-agent | Correct design |
| skill-meta | Yes | meta-builder-agent | Correct design |
| skill-filetypes | Yes | filetypes-router-agent | Correct design |
| skill-remember | Yes | remember-agent | Correct design |
| skill-orchestrator | Yes | (routing only) | Correct design |
| skill-learn | No (direct) | N/A | Utility skill |
| skill-refresh | No (direct) | N/A | Utility skill |
| skill-status-sync | No (direct) | N/A | Utility skill |
| skill-git-workflow | No (direct) | N/A | Utility skill |

Finding: Skills that delegate to agents ARE correctly designed to use Task tool.

## Key Evidence from skill-filetypes/SKILL.md (lines 112-126)

CRITICAL: You MUST use the Task tool to spawn the router agent.

Required Tool Invocation:
- Tool: Task (NOT Skill)
- Parameters: subagent_type, prompt, description

DO NOT use Skill(filetypes-router-agent) - this will FAIL.
Agents live in .opencode/agents/ or extension agent directories, not .opencode/skills/.
The Skill tool can only invoke skills from .opencode/skills/.

## The Problem

When a workflow command runs:
1. Command spec is loaded - YES
2. Command steps are executed (look up task, validate status, etc.) - YES
3. Skill invocation fails - Skill content displayed instead of executed - NO
4. Task tool never invoked - No subagent delegation occurs - NO

Symptoms from OC_138 incident:
- Skill "skill-planner" displays skill content
- Command steps continue executing
- But skill stages never run

## Root Cause

The command specifications describe the workflow but don't actually invoke the skill tool. When the command processing engine sees "The skill displays...", it outputs skill content for reference but doesn't execute the skill's stages.

The fix needs to add explicit skill tool invocation to command specifications.
