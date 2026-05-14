# Research Report: Task #506 - Core Context System Expansion

**Task**: OC_506 - expand_core_context_system
**Started**: 2026-05-02
**Completed**: 2026-05-02
**Effort**: 2 hours
**Dependencies**: None
**Sources/Inputs**: 
- `.claude/extensions/core/context/` (source)
- `.opencode/context/` (target)
- `index.schema.json` (schema)
- `index.md` (reference)

**Artifacts**: - This report

**Standards**: report-format.md

---

## Executive Summary

The task requires expanding `.opencode/context/` to match the structure of `.claude/extensions/core/context/`. Analysis reveals **6 missing directories** in `.opencode/context/core/` containing **18 files** that need to be copied from the source:

1. **guides/** (2 files) - Extension development guides
2. **meta/** (3 files) - Meta-builder domain patterns
3. **processes/** (3 files) - Workflow process documentation  
4. **reference/** (6 files) - Quick reference materials
5. **repo/** (3 files) - Repository management guides
6. **troubleshooting/** (1 file) - Workflow troubleshooting

Total: 6 directories, 18 files

---

## Context & Scope

### Source Structure (.claude/extensions/core/context/)
The source directory contains 18 subdirectories with organized context files:

```
.claude/extensions/core/context/
├── README.md
├── index.schema.json
├── architecture/          (4 files)
├── checkpoints/           (4 files)
├── formats/               (13 files)
├── guides/                (2 files)  <- MISSING in target
├── meta/                  (3 files)  <- MISSING in target
├── orchestration/         (12 files)
├── patterns/              (16 files)
├── processes/             (3 files)  <- MISSING in target
├── reference/             (6 files)  <- MISSING in target
├── repo/                  (3 files)  <- MISSING in target
├── schemas/               (2 files)
├── standards/             (13 files)
├── templates/             (7 files)
├── troubleshooting/       (1 file)   <- MISSING in target
└── workflows/             (5 files)
```

### Target Structure (.opencode/context/)
The target currently has:

```
.opencode/context/
├── README.md
├── index.md
├── core/
│   ├── architecture/      (4 files)  - MATCHES
│   ├── checkpoints/       (4 files)  - MATCHES
│   ├── formats/           (12 files) - 1 LESS
│   ├── orchestration/     (12 files) - MATCHES
│   ├── patterns/          (15 files) - 1 LESS
│   ├── schemas/           (2 files)  - MATCHES
│   ├── standards/         (13 files) - MATCHES
│   ├── templates/         (7 files)  - MATCHES
│   └── workflows/         (5 files)  - MATCHES
└── project/
    ├── hooks/             (2 files)  - EXTRA
    ├── meta/              (4 files)  - AT WRONG LEVEL
    ├── processes/         (3 files)  - AT WRONG LEVEL
    └── repo/              (3 files)  - AT WRONG LEVEL
```

---

## Findings

### 1. Missing Directories in core/

Six directories are completely absent from `.opencode/context/core/`:

| Directory | Files | Purpose |
|-----------|-------|---------|
| `guides/` | 2 | Extension development and loader reference |
| `meta/` | 3 | Meta-builder patterns and domain recognition |
| `processes/` | 3 | Research/planning/implementation workflows |
| `reference/` | 6 | Quick references, diagrams, mapping tables |
| `repo/` | 3 | Project overview and update guides |
| `troubleshooting/` | 1 | Workflow interruption diagnostics |

### 2. Content Mismatch

Some content exists in `.opencode/` but at different locations:

| Content | Source Location | Target Location | Status |
|---------|-----------------|-----------------|--------|
| meta files | `core/meta/` | `project/meta/` | WRONG LEVEL |
| process files | `core/processes/` | `project/processes/` | WRONG LEVEL |
| repo files | `core/repo/` | `project/repo/` | WRONG LEVEL |

### 3. File Inventory

#### guides/ (2 files)
- `extension-development.md` (255 lines) - Extension development guide
- `loader-reference.md` - Context loader reference

#### meta/ (3 files)
- `meta-guide.md` (259 lines) - /meta command reference
- `domain-patterns.md` - Domain pattern recognition
- `context-revision-guide.md` - Context revision patterns

#### processes/ (3 files)
- `research-workflow.md` - Research workflow documentation
- `planning-workflow.md` - Planning workflow documentation
- `implementation-workflow.md` - Implementation workflow documentation

#### reference/ (6 files)
- `README.md` - Reference index
- `state-management-schema.md` - State schema reference
- `skill-agent-mapping.md` - Skill to agent mapping
- `team-wave-helpers.md` - Team wave helpers
- `workflow-diagrams.md` - Workflow diagrams
- `artifact-templates.md` - Artifact templates

#### repo/ (3 files)
- `project-overview.md` - Repository structure overview
- `update-project.md` - Project overview update guide
- `self-healing-implementation-details.md` - Self-healing details

#### troubleshooting/ (1 file)
- `workflow-interruptions.md` (335 lines) - Troubleshooting guide

### 4. Schema Analysis

The source includes `index.schema.json` which defines the machine-readable context index format. This schema supports:
- Path resolution
- Domain/subdomain categorization
- Topic and keyword tagging
- Automatic loading conditions (agents, commands, languages)
- Deprecation tracking

The target has `index.md` (human-readable) but should also include the schema for programmatic access.

### 5. Cross-Reference Analysis

Key cross-references identified in the source files:

**From troubleshooting/workflow-interruptions.md:**
- References: `patterns/postflight-control.md`
- References: `formats/return-metadata-file.md`
- References: `patterns/file-metadata-exchange.md`

**From guides/extension-development.md:**
- References: `../../docs/architecture/extension-system.md`
- References: Manifest format and `index-entries.json`

**From meta/meta-guide.md:**
- References: `orchestration/architecture.md`
- References: `standards/multi-task-creation-standard.md`

### 6. Dependency Mapping

The missing files have these dependency relationships:

```
guides/extension-development.md
  -> Requires: architecture/extension-system.md (external)

meta/meta-guide.md
  -> Requires: orchestration/architecture.md (exists)
  -> Requires: standards/delegation.md (exists)

troubleshooting/workflow-interruptions.md
  -> Requires: patterns/postflight-control.md (exists)
  -> Requires: formats/return-metadata-file.md (exists)
  -> Requires: patterns/file-metadata-exchange.md (exists)

reference/skill-agent-mapping.md
  -> Standalone reference table

processes/*.md
  -> Reference existing workflow patterns
  -> Standalone process documentation
```

---

## Recommendations

### Phase 1: Create Missing Directories
Create the 6 missing directories in `.opencode/context/core/`:

```bash
mkdir -p .opencode/context/core/{guides,meta,processes,reference,repo,troubleshooting}
```

### Phase 2: Copy Files
Copy all 18 files from source to target. Suggested approach:

```bash
# guides/
cp .claude/extensions/core/context/guides/*.md .opencode/context/core/guides/

# meta/
cp .claude/extensions/core/context/meta/*.md .opencode/context/core/meta/

# processes/
cp .claude/extensions/core/context/processes/*.md .opencode/context/core/processes/

# reference/
cp .claude/extensions/core/context/reference/*.md .opencode/context/core/reference/

# repo/
cp .claude/extensions/core/context/repo/*.md .opencode/context/core/repo/

# troubleshooting/
cp .claude/extensions/core/context/troubleshooting/*.md .opencode/context/core/troubleshooting/
```

### Phase 3: Add index.schema.json
Copy the schema file for programmatic context discovery:

```bash
cp .claude/extensions/core/context/index.schema.json .opencode/context/
```

### Phase 4: Update index.md
Update `.opencode/context/index.md` to include references to the new directories.

### Phase 5: Validation
Run validation to ensure:
- All files copied successfully
- No broken cross-references
- Files are readable and correctly formatted

---

## Decisions

1. **Copy vs. Symlink**: Decision to copy files (not symlink) to allow independent evolution of `.opencode/` structure.

2. **Directory Structure**: Maintain parallel structure to `.claude/` for ease of maintenance and understanding.

3. **Content Level**: The content in `project/` that belongs in `core/` should be kept in `project/` (already there) and additionally copied to `core/`, maintaining backward compatibility.

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Duplicate content | Medium | Document which location is authoritative; eventually deprecate `project/` versions |
| Broken cross-references | Low | Validate all internal links after copying |
| Out of sync with source | Medium | Document sync process; consider automation |
| Index.md out of date | Medium | Update index.md with new sections |

---

## Context Extension Recommendations

**None required** - This is a meta task about context system structure itself. No new context documentation is needed.

---

## Appendix A: Complete File List

### guides/ (2 files, ~300 lines estimated)
1. `loader-reference.md`
2. `extension-development.md` (255 lines)

### meta/ (3 files, ~600 lines estimated)
1. `meta-guide.md` (259 lines)
2. `domain-patterns.md`
3. `context-revision-guide.md`

### processes/ (3 files, ~450 lines estimated)
1. `research-workflow.md`
2. `planning-workflow.md`
3. `implementation-workflow.md`

### reference/ (6 files, ~900 lines estimated)
1. `README.md`
2. `state-management-schema.md`
3. `skill-agent-mapping.md`
4. `team-wave-helpers.md`
5. `workflow-diagrams.md`
6. `artifact-templates.md`

### repo/ (3 files, ~600 lines estimated)
1. `project-overview.md`
2. `update-project.md`
3. `self-healing-implementation-details.md`

### troubleshooting/ (1 file, 335 lines)
1. `workflow-interruptions.md` (335 lines)

**Total**: 18 files, ~3,185 lines of documentation

---

## Appendix B: Source vs Target Comparison Table

| Directory | Source Files | Target Files | Status |
|-----------|--------------|--------------|--------|
| architecture/ | 4 | 4 | MATCH |
| checkpoints/ | 4 | 4 | MATCH |
| formats/ | 13 | 12 | -1 file |
| guides/ | 2 | 0 | MISSING |
| meta/ | 3 | 0* | MISSING |
| orchestration/ | 12 | 12 | MATCH |
| patterns/ | 16 | 15 | -1 file |
| processes/ | 3 | 0* | MISSING |
| reference/ | 6 | 0 | MISSING |
| repo/ | 3 | 0* | MISSING |
| schemas/ | 2 | 2 | MATCH |
| standards/ | 13 | 13 | MATCH |
| templates/ | 7 | 7 | MATCH |
| troubleshooting/ | 1 | 0 | MISSING |
| workflows/ | 5 | 5 | MATCH |

*Content exists in `project/` subdirectory instead of `core/`
