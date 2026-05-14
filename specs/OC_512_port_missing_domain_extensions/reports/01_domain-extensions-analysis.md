# Research Report: Task #512

**Task**: OC_512 - Port Missing Domain Extensions
**Started**: 2026-05-02T00:00:00Z
**Completed**: 2026-05-02T00:45:00Z
**Effort**: 2-3 hours
**Dependencies**: None
**Sources/Inputs**: 
- `.claude/extensions/founder/` - Source extension
- `.claude/extensions/present/` - Source extension
- `.claude/extensions/slidev/` - Source extension
- `.opencode/extensions/nix/` - Reference ported extension
- `.opencode/extensions/typst/` - Reference ported extension
- `.opencode/extensions/memory/` - Reference ported extension

**Artifacts**: 
- `specs/OC_512_port_missing_domain_extensions/reports/01_domain-extensions-analysis.md` (this report)

**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

Three domain extensions need to be ported from `.claude/extensions/` to `.opencode/extensions/`:

1. **founder/** - Strategic business analysis extension with 9 commands, 16 agents, 15 skills
2. **present/** - Research presentation support with 5 commands, 9 agents, 7 skills
3. **slidev/** - Shared Slidev resources extension with no commands (dependency-only)

**Key Findings**:
- Total of 183 files to port across 3 extensions (~37,000 lines)
- Complex routing tables and merge_targets require careful adaptation
- Slidev is a shared dependency for both founder and present extensions
- Present extension has an `opencode-agents.json` file already prepared
- Several path adaptations needed from `.claude/` to `.opencode/`

**Recommended Approach**:
- Port slidev first (dependency for both founder and present)
- Then port present (smaller, has opencode-agents.json already)
- Finally port founder (largest, most complex)

---

## Context & Scope

This research analyzes three domain extensions currently in `.claude/extensions/` that need to be ported to `.opencode/extensions/` to make them available in the OpenCode system.

**Scope**:
1. Analyze structure and content of each source extension
2. Map required path adaptations
3. Identify manifest.json changes needed
4. Document file counts and complexity
5. Provide implementation recommendations

---

## Findings

### Extension 1: founder/

**Purpose**: Strategic business analysis for founders with market sizing, competitive analysis, GTM strategy, contract review, and project timeline management.

**Structure**:
```
founder/
├── manifest.json              # Extension configuration
├── EXTENSION.md               # CLAUDE.md merge content
├── index-entries.json         # Context discovery entries (710 lines)
├── README.md                  # User documentation (422 lines)
│
├── commands/                  # 9 slash commands
│   ├── market.md
│   ├── analyze.md
│   ├── strategy.md
│   ├── legal.md
│   ├── project.md
│   ├── deck.md
│   ├── finance.md
│   ├── sheet.md
│   ├── meeting.md
│   └── consult.md
│
├── skills/                    # 15 skill wrappers
│   ├── skill-market/
│   ├── skill-analyze/
│   ├── skill-strategy/
│   ├── skill-legal/
│   ├── skill-project/
│   ├── skill-deck-research/
│   ├── skill-deck-plan/
│   ├── skill-deck-implement/
│   ├── skill-finance/
│   ├── skill-founder-spreadsheet/
│   ├── skill-meeting/
│   ├── skill-consult/
│   ├── skill-founder-plan/
│   └── skill-founder-implement/
│
├── agents/                    # 16 agent definitions
│   ├── market-agent.md
│   ├── analyze-agent.md
│   ├── strategy-agent.md
│   ├── legal-council-agent.md
│   ├── project-agent.md
│   ├── deck-research-agent.md
│   ├── deck-planner-agent.md
│   ├── deck-builder-agent.md
│   ├── finance-agent.md
│   ├── financial-analysis-agent.md
│   ├── founder-spreadsheet-agent.md
│   ├── legal-analysis-agent.md
│   ├── meeting-agent.md
│   ├── founder-plan-agent.md
│   └── founder-implement-agent.md
│
└── context/
    └── project/
        └── founder/
            ├── README.md
            ├── deck/                  # Deck-specific context
            │   ├── index.json
            │   ├── components/
            │   ├── contents/
            │   ├── patterns/
            │   └── themes/
            ├── domain/                # Business frameworks
            │   ├── business-frameworks.md
            │   ├── strategic-thinking.md
            │   ├── legal-frameworks.md
            │   ├── timeline-frameworks.md
            │   ├── spreadsheet-frameworks.md
            │   ├── financial-analysis.md
            │   ├── workflow-reference.md
            │   └── migration-guide.md
            ├── patterns/              # Analysis patterns
            │   ├── forcing-questions.md
            │   ├── decision-making.md
            │   ├── mode-selection.md
            │   ├── contract-review.md
            │   ├── legal-planning.md
            │   ├── project-planning.md
            │   ├── pitch-deck-structure.md
            │   ├── slidev-deck-template.md
            │   ├── yc-compliance-checklist.md
            │   ├── csv-tracker.md
            │   ├── cost-forcing-questions.md
            │   └── financial-forcing-questions.md
            └── templates/             # Output templates
                ├── market-sizing.md
                ├── competitive-analysis.md
                ├── gtm-strategy.md
                ├── contract-analysis.md
                ├── meeting-format.md
                ├── financial-analysis.md
                └── typst/               # Typst templates
```

**File Count**: ~120 files

**Key Manifest Fields**:
- `name`: "founder"
- `version`: "3.0.0"
- `task_type`: "founder"
- `dependencies`: ["core", "slidev"]
- `routing`: Complex 3-phase routing (research, plan, implement)
- `merge_targets`: 
  - `claudemd`: `.claude/CLAUDE.md` (section_id: "extension_founder")
  - `index`: `.claude/context/index.json`
- `mcp_servers`: sec-edgar, firecrawl

**Required Adaptations**:
1. `merge_targets.claudemd.target` → `.opencode/AGENTS.md`
2. `merge_targets.index.target` → `.opencode/context/index.json`
3. `merge_targets.claudemd.section_id` → "extension_oc_founder"
4. Add `language` field (value: "founder")
5. Consider adding `settings-fragment.json` for MCP servers

---

### Extension 2: present/

**Purpose**: Research presentation support including grant writing, budget planning, timeline management, funding analysis, and academic talks.

**Structure**:
```
present/
├── manifest.json              # Extension configuration
├── EXTENSION.md               # CLAUDE.md merge content
├── index-entries.json         # Context discovery entries (508 lines)
├── opencode-agents.json       # OpenCode agent definitions (already exists!)
├── README.md                  # User documentation (218 lines)
│
├── commands/                  # 5 slash commands
│   ├── grant.md
│   ├── budget.md
│   ├── timeline.md
│   ├── funds.md
│   └── slides.md
│
├── skills/                    # 7 skill wrappers
│   ├── skill-grant/
│   ├── skill-budget/
│   ├── skill-timeline/
│   ├── skill-funds/
│   ├── skill-slides/
│   ├── skill-slide-planning/
│   └── skill-slide-critic/
│
├── agents/                    # 9 agent definitions
│   ├── grant-agent.md
│   ├── budget-agent.md
│   ├── timeline-agent.md
│   ├── funds-agent.md
│   ├── slides-research-agent.md
│   ├── pptx-assembly-agent.md
│   ├── slidev-assembly-agent.md
│   ├── slide-planner-agent.md
│   └── slide-critic-agent.md
│
└── context/
    └── project/
        └── present/
            ├── domain/                # Grant writing concepts
            │   ├── funder-types.md
            │   ├── proposal-components.md
            │   ├── grant-terminology.md
            │   ├── grant-workflow.md
            │   ├── grant-budget-frameworks.md
            │   ├── research-timelines.md
            │   ├── funding-analysis.md
            │   └── presentation-types.md
            ├── patterns/              # Proposal patterns
            │   ├── proposal-structure.md
            │   ├── budget-patterns.md
            │   ├── evaluation-patterns.md
            │   ├── narrative-patterns.md
            │   ├── talk-structure.md
            │   ├── budget-forcing-questions.md
            │   ├── funding-forcing-questions.md
            │   └── timeline-patterns.md
            ├── standards/
            │   ├── writing-standards.md
            │   └── character-limits.md
            ├── templates/
            │   ├── executive-summary.md
            │   ├── budget-justification.md
            │   ├── evaluation-plan.md
            │   ├── submission-checklist.md
            │   ├── timeline-template.md
            │   └── typst/research-timeline.typ
            ├── tools/
            │   ├── funder-research.md
            │   └── web-resources.md
            └── talk/                  # Talk library
                ├── index.json
                ├── critique-rubric.md
                ├── components/
                ├── contents/
                ├── patterns/
                ├── templates/
                └── themes/
```

**File Count**: ~50 files

**Key Manifest Fields**:
- `name`: "present"
- `version`: "1.0.0"
- `task_type`: "present"
- `dependencies`: ["core", "slidev"]
- `routing`: Includes critique phase
- `merge_targets`:
  - `claudemd`: `.claude/CLAUDE.md` (section_id: "extension_present")
  - `index`: `.claude/context/index.json`
  - `opencode_json`: `opencode.json` (targets opencode.json)
- `mcp_servers`: superdoc

**Special Note**: This extension already has `opencode-agents.json` prepared!

**Required Adaptations**:
1. `merge_targets.claudemd.target` → `.opencode/AGENTS.md`
2. `merge_targets.index.target` → `.opencode/context/index.json`
3. `merge_targets.claudemd.section_id` → "extension_oc_present"
4. Remove or adapt `merge_targets.opencode_json` (may need custom handling)
5. Add `language` field (value: "present")

---

### Extension 3: slidev/

**Purpose**: Shared Slidev animation patterns and CSS style presets. Resource-only extension (no agents, commands, or routing).

**Structure**:
```
slidev/
├── manifest.json              # Extension configuration
├── EXTENSION.md               # CLAUDE.md merge content
├── index-entries.json         # Context discovery entries (169 lines)
├── README.md                  # User documentation (85 lines)
│
└── context/
    └── project/
        └── slidev/
            ├── animation/           # 6 animation patterns
            │   ├── fade-in.md
            │   ├── slide-in-below.md
            │   ├── metric-cascade.md
            │   ├── rough-marks.md
            │   ├── staggered-list.md
            │   └── scale-in-pop.md
            └── style/
                ├── colors/          # 4 color schemes
                │   ├── light-blue-corp.css
                │   ├── dark-blue-navy.css
                │   ├── dark-gold-premium.css
                │   └── light-green-growth.css
                ├── typography/      # 3 typography stacks
                │   ├── montserrat-inter.css
                │   ├── playfair-inter.css
                │   └── inter-only.css
                └── textures/        # 2 texture overlays
                    ├── grid-overlay.css
                    └── noise-grain.css
```

**File Count**: ~15 files

**Key Manifest Fields**:
- `name`: "slidev"
- `version`: "1.0.0"
- `routing_exempt`: true (no commands/routing)
- `dependencies`: ["core"]
- `merge_targets`:
  - `index`: `.claude/context/index.json`

**Required Adaptations**:
1. `merge_targets.index.target` → `.opencode/context/index.json`
2. No `claudemd` merge target (no agents/commands to document)
3. Consider adding `language: "slidev"` or leaving as null

---

## Path Adaptations Required

### File Path Changes

| Source Path | Target Path | Notes |
|-------------|-------------|-------|
| `.claude/extensions/{ext}/` | `.opencode/extensions/{ext}/` | Base directory |
| `.claude/context/index.json` | `.opencode/context/index.json` | Index merge target |
| `.claude/CLAUDE.md` | `.opencode/AGENTS.md` | Documentation merge target |
| `opencode.json` | (review needed) | May need custom handling |

### Content Path References

The following path references within files need updating:

**In SKILL.md files**:
- References to `.claude/context/` → `.opencode/context/`
- References to `.claude/extensions/` → `.opencode/extensions/`
- References to `specs/TODO.md` → `specs/TODO.md` (unchanged)
- References to `specs/state.json` → `specs/state.json` (unchanged)

**In agent files**:
- `@.claude/context/` → `@.opencode/context/`
- `@.claude/extensions/` → `@.opencode/extensions/`

**In command files**:
- Path references in bash scripts for specs/ can remain (shared)

---

## Manifest.json Comparison

### Source (Claude) vs Target (OpenCode) Patterns

**Claude Extension**:
```json
{
  "name": "example",
  "version": "1.0.0",
  "task_type": "example",
  "dependencies": ["core"],
  "merge_targets": {
    "claudemd": {
      "source": "EXTENSION.md",
      "target": ".claude/CLAUDE.md",
      "section_id": "extension_example"
    },
    "index": {
      "source": "index-entries.json",
      "target": ".claude/context/index.json"
    }
  }
}
```

**OpenCode Extension**:
```json
{
  "name": "example",
  "version": "1.0.0",
  "language": "example",
  "dependencies": [],
  "merge_targets": {
    "opencode_md": {
      "source": "EXTENSION.md",
      "target": ".opencode/AGENTS.md",
      "section_id": "extension_oc_example"
    },
    "index": {
      "source": "index-entries.json",
      "target": ".opencode/context/index.json"
    }
  }
}
```

**Key Differences**:
1. `task_type` → `language`
2. `merge_targets.claudemd` → `merge_targets.opencode_md`
3. Target paths use `.opencode/` instead of `.claude/`
4. `section_id` prefixes with "extension_oc_" for OpenCode

---

## Dependency Chain

```
slidev (dependency-only)
    ↑
    ├── founder (depends on slidev)
    │
    └── present (depends on slidev)
```

**Porting Order**:
1. **slidev** first (both founder and present depend on it)
2. **present** second (smaller, has opencode-agents.json ready)
3. **founder** third (largest and most complex)

---

## Decisions

### Decision 1: Port slidev First
**Rationale**: Both founder and present extensions declare slidev as a dependency. The extension loader needs slidev available before dependent extensions.

### Decision 2: Handle opencode-agents.json Separately
**Rationale**: The present extension has an `opencode-agents.json` file with a merge target of `opencode.json`. This appears to be a different merge mechanism. Need to verify if:
- This file should be copied as-is
- It needs a different merge target in OpenCode
- It should be integrated differently

### Decision 3: Maintain Context Path Structure
**Rationale**: Context files within the extension (e.g., `context/project/founder/`) should maintain their internal structure. Only the root references need changing.

### Decision 4: Keep Shared specs/ References
**Rationale**: References to `specs/TODO.md`, `specs/state.json`, etc. should remain unchanged as these are shared between systems.

---

## Risks & Mitigations

### Risk 1: Path References in Content
**Risk**: Many files contain hardcoded references to `.claude/` paths.
**Mitigation**: Perform global search/replace after copying, or create a transformation script.

### Risk 2: MCP Server Configuration
**Risk**: MCP servers may need different configuration in OpenCode vs Claude.
**Mitigation**: Review each MCP server and create appropriate `settings-fragment.json` if needed.

### Risk 3: Extension Interdependencies
**Risk**: Extensions may have undocumented dependencies or shared patterns.
**Mitigation**: Test each extension after porting before moving to the next.

### Risk 4: Context Index Format Differences
**Risk**: The index-entries.json format may differ between systems.
**Mitigation**: Compare existing ported extension index files to ensure compatibility.

---

## Implementation Recommendations

### Phase 1: slidev Extension
1. Copy all files from `.claude/extensions/slidev/` to `.opencode/extensions/slidev/`
2. Update `manifest.json`:
   - Add `"language": "slidev"`
   - Change `merge_targets.index.target` to `.opencode/context/index.json`
3. No `claudemd` merge target needed (no agents/commands)
4. Verify by checking that index entries are valid

**Estimated Effort**: 30 minutes
**Risk Level**: Low (no agents/commands, simple structure)

### Phase 2: present Extension
1. Copy all files from `.claude/extensions/present/` to `.opencode/extensions/present/`
2. Update `manifest.json`:
   - Change `"task_type": "present"` to `"language": "present"`
   - Change `merge_targets.claudemd.target` to `.opencode/AGENTS.md`
   - Change `merge_targets.claudemd.section_id` to `extension_oc_present`
   - Change `merge_targets.index.target` to `.opencode/context/index.json`
   - Review `merge_targets.opencode_json` - may need removal or adaptation
3. Update path references in agent and skill files
4. Verify `opencode-agents.json` is compatible

**Estimated Effort**: 1-2 hours
**Risk Level**: Medium (has opencode-agents.json already, reducing risk)

### Phase 3: founder Extension
1. Copy all files from `.claude/extensions/founder/` to `.opencode/extensions/founder/`
2. Update `manifest.json`:
   - Change `"task_type": "founder"` to `"language": "founder"`
   - Change `merge_targets.claudemd.target` to `.opencode/AGENTS.md`
   - Change `merge_targets.claudemd.section_id` to `extension_oc_founder`
   - Change `merge_targets.index.target` to `.opencode/context/index.json`
   - Consider adding `settings-fragment.json` for MCP servers
3. Update path references in all 16 agents and 15 skills
4. Verify routing tables work with OpenCode system

**Estimated Effort**: 2-3 hours
**Risk Level**: Medium-High (most complex, many files)

---

## File Count Summary

| Extension | Files | Context Files | Skills | Agents | Commands | Lines (est.) |
|-----------|-------|---------------|--------|--------|----------|--------------|
| slidev | 15 | 15 | 0 | 0 | 0 | ~1,000 |
| present | 50 | 40 | 7 | 9 | 5 | ~12,000 |
| founder | 120 | 90 | 15 | 16 | 9 | ~24,000 |
| **Total** | **~185** | **~145** | **22** | **25** | **14** | **~37,000** |

---

## Context Extension Recommendations

**None required** - This is a porting task, not a new feature. The extensions are already well-documented.

However, after porting, consider documenting the porting process in:
- `.opencode/context/guides/extension-porting.md` - For future extension ports

---

## Appendix: Detailed File Lists

### founder/ File List (120 files)
```
manifest.json, EXTENSION.md, README.md, index-entries.json
commands/: 10 files
skills/: 15 files
agents/: 16 files
context/project/founder/: ~80 files (domain, patterns, templates, deck)
```

### present/ File List (50 files)
```
manifest.json, EXTENSION.md, README.md, index-entries.json, opencode-agents.json
commands/: 5 files
skills/: 7 files
agents/: 9 files
context/project/present/: ~30 files (domain, patterns, templates, talk)
```

### slidev/ File List (15 files)
```
manifest.json, EXTENSION.md, README.md, index-entries.json
context/project/slidev/: 15 files (6 animations, 9 styles)
```

---

## Next Steps

1. **Create implementation plan** for the three extensions using `/plan 512`
2. **Port slidev first** as it's the dependency for both other extensions
3. **Port present second** leveraging the existing opencode-agents.json
4. **Port founder last** as it's the largest and most complex
5. **Test each extension** after porting to verify functionality

---

*Report generated by general-research-agent for Task #512*
