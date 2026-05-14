# Skill File Structure Standard

**Version**: 2.0
**Updated**: 2026-03-04 (Push Context Model)
**Scope**: All `.opencode/skills/*/SKILL.md` files.

## Overview

Skills are thin wrappers around agents. The "Push Context" model requires skills to eagerly load critical context files and inject them directly into the agent's prompt via the `Task` tool. This replaces the deprecated "Pull" model where agents were expected to load context on-demand.

## Structure

A standard `SKILL.md` file consists of:
1. **Frontmatter**: Metadata defining the skill name, description, allowed tools, and execution context.
2. **Context Injection**: XML blocks defining what context to load and inject.
3. **Execution Flow**: Step-by-step instructions for the skill executor (orchestrator).

## YAML Frontmatter (Required)

```yaml
---
name: skill-{name}
description: "Brief description"
allowed-tools: Task, Bash, Edit, Read
context: fork
agent: {subagent-name}
---
```

## XML Body Structure

```xml
<context>
  <system_context>...</system_context>
  <task_context>...</task_context>
</context>

<context_injection>
  <file path=".opencode/context/core/formats/plan-format.md" variable="plan_format" />
  <file path=".opencode/context/core/standards/status-markers.md" variable="status_markers" />
</context_injection>

<role>
  ...
</role>

<task>
  ...
</task>

<execution>
  <stage id="1" name="LoadContext">
    <action>Read context files defined in <context_injection></action>
  </stage>
  <stage id="2" name="Delegate">
    <action>Invoke subagent with injected context</action>
  </stage>
</execution>

<validation>
  <checks>...</checks>
</validation>

<return_format>
  ...
</return_format>
```

## Context Injection Pattern

The skill executor MUST:
1. Read each file defined in `<context_injection>`.
2. Store the content in the specified variable.
3. Append the content to the `prompt` argument of the `Task` tool.

## Execution Flow Template

```markdown
## Execution Flow

1. **Load Context**:
   - Read `plan-format.md` -> `{plan_format}`
   - Read `status-markers.md` -> `{status_markers}`

2. **Delegate**:
   - Call `Task` tool with `subagent_type="target-agent"`
   - Prompt:
     """
     {User Task Description}

     <system_context>
     Using the following format standards:
     {plan_format}
     {status_markers}
     </system_context>
     """
```

## Benefits

- **Reliability**: Agents cannot "forget" to load context.
- **Consistency**: All agents receive the exact same version of the standards.
- **Performance**: Reduces the number of tool calls (no `Read` calls needed by the agent).
