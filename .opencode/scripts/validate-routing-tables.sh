#!/usr/bin/env bash
# validate-routing-tables.sh
# Validates extension manifest routing integrity and checks for hardcoded tables

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

MANIFEST_DIR="$PROJECT_ROOT/.opencode/extensions"
COMMANDS_DIR="$PROJECT_ROOT/.opencode/commands"

ERRORS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== Extension Routing Validation ==="
echo ""

# Step 1: Extract all routing entries and skills from manifests
declare -A MANIFEST_TASKS
declare -A MANIFEST_SKILLS
declare -A EXTENSION_SKILLS
declare -a EXTENSION_NAMES

for manifest in "$MANIFEST_DIR"/*/manifest.json; do
  if [ -f "$manifest" ]; then
    ext_name=$(basename "$(dirname "$manifest")")
    EXTENSION_NAMES+=("$ext_name")

    # Collect all skills provided by this extension
    skills=$(jq -r '.provides.skills // [] | .[]' "$manifest" 2>/dev/null || true)
    for skill in $skills; do
      EXTENSION_SKILLS["${ext_name}:${skill}"]="1"
    done

    # Collect all routing entries
    for routing_type in implement research plan critique; do
      task_types=$(jq -r --arg rt "$routing_type" '.routing[$rt] // {} | keys[]' "$manifest" 2>/dev/null || true)
      for task_type in $task_types; do
        skill=$(jq -r --arg rt "$routing_type" --arg tt "$task_type" '.routing[$rt][$tt] // empty' "$manifest")
        if [ -n "$skill" ]; then
          key="${routing_type}:${task_type}"
          MANIFEST_TASKS["$key"]="$ext_name"
          MANIFEST_SKILLS["$key"]="$skill"
        fi
      done
    done
  fi
done

echo "Found ${#MANIFEST_TASKS[@]} routing entries in manifests"
echo "Found ${#EXTENSION_NAMES[@]} extensions"
echo ""

# New Check A — Skill Coverage
# Every skill in provides.skills must have at least one routing entry
# (unless extension has routing_exempt: true or is utility/dependency-only)
echo "=== Check A: Skill Coverage ==="
SKILL_COVERAGE_ERRORS=0

for manifest in "$MANIFEST_DIR"/*/manifest.json; do
  if [ -f "$manifest" ]; then
    ext_name=$(basename "$(dirname "$manifest")")

    # Skip exempt extensions
    routing_exempt=$(jq -r '.routing_exempt // false' "$manifest")
    if [ "$routing_exempt" = "true" ]; then
      continue
    fi

    # Skip utility/dependency-only extensions
    case "$ext_name" in
      memory|slidev)
        continue
        ;;
    esac

    skills=$(jq -r '.provides.skills // [] | .[]' "$manifest" 2>/dev/null || true)
    for skill in $skills; do
      found="false"
      # Check if this skill appears in any routing entry for this extension
      for key in "${!MANIFEST_SKILLS[@]}"; do
        if [ "${MANIFEST_TASKS[$key]}" = "$ext_name" ] && [ "${MANIFEST_SKILLS[$key]}" = "$skill" ]; then
          found="true"
          break
        fi
      done
      if [ "$found" = "false" ]; then
        echo -e "${RED}FAIL${NC}: Extension '$ext_name' skill '$skill' has no routing entry"
        SKILL_COVERAGE_ERRORS=$((SKILL_COVERAGE_ERRORS + 1))
      fi
    done
  fi
done

if [ "$SKILL_COVERAGE_ERRORS" -eq 0 ]; then
  echo -e "${GREEN}All skills have routing coverage${NC}"
else
  ERRORS=$((ERRORS + SKILL_COVERAGE_ERRORS))
fi

echo ""

# New Check B — Routing Integrity
# Every routing.*.* value must exist in the same manifest's provides.skills
# (or be explicitly documented as cross-extension)
echo "=== Check B: Routing Integrity ==="
ROUTING_ERRORS=0

for manifest in "$MANIFEST_DIR"/*/manifest.json; do
  if [ -f "$manifest" ]; then
    ext_name=$(basename "$(dirname "$manifest")")

    # Build set of skills provided by this extension
    declare -A local_skills
    skills=$(jq -r '.provides.skills // [] | .[]' "$manifest" 2>/dev/null || true)
    for skill in $skills; do
      local_skills["$skill"]="1"
    done

    # Check every routing value against local skills
    for routing_type in implement research plan critique; do
      task_types=$(jq -r --arg rt "$routing_type" '.routing[$rt] // {} | keys[]' "$manifest" 2>/dev/null || true)
      for task_type in $task_types; do
        skill=$(jq -r --arg rt "$routing_type" --arg tt "$task_type" '.routing[$rt][$tt] // empty' "$manifest")
        if [ -n "$skill" ]; then
          # Allow-list known cross-extension references (currently none after Phase 2)
          # If cross-extension routing is needed, document it here
          if [ -z "${local_skills[$skill]+x}" ]; then
            echo -e "${RED}FAIL${NC}: Extension '$ext_name' routing ${routing_type}.${task_type} -> '$skill' not in provides.skills"
            ROUTING_ERRORS=$((ROUTING_ERRORS + 1))
          fi
        fi
      done
    done

    unset local_skills
  fi
done

if [ "$ROUTING_ERRORS" -eq 0 ]; then
  echo -e "${GREEN}All routing entries are valid${NC}"
else
  ERRORS=$((ERRORS + ROUTING_ERRORS))
fi

echo ""

# New Check C — No Hardcoded Tables
echo "=== Check C: No Hardcoded Routing Tables ==="
TABLE_ERRORS=0

for cmd in implement research plan; do
  if [ -f "$COMMANDS_DIR/${cmd}.md" ]; then
    if grep -q "Extension-Based Routing Table" "$COMMANDS_DIR/${cmd}.md"; then
      echo -e "${RED}FAIL${NC}: Hardcoded table found in ${cmd}.md"
      TABLE_ERRORS=$((TABLE_ERRORS + 1))
    fi
  fi
done

if [ "$TABLE_ERRORS" -eq 0 ]; then
  echo -e "${GREEN}No hardcoded routing tables found${NC}"
else
  ERRORS=$((ERRORS + TABLE_ERRORS))
fi

echo ""

# New Check D — Valid JSON
echo "=== Check D: Valid JSON ==="
JSON_ERRORS=0

for manifest in "$MANIFEST_DIR"/*/manifest.json; do
  if [ -f "$manifest" ]; then
    if ! jq empty "$manifest" 2>/dev/null; then
      echo -e "${RED}FAIL${NC}: Invalid JSON in $manifest"
      JSON_ERRORS=$((JSON_ERRORS + 1))
    fi
  fi
done

if [ "$JSON_ERRORS" -eq 0 ]; then
  echo -e "${GREEN}All manifests are valid JSON${NC}"
else
  ERRORS=$((ERRORS + JSON_ERRORS))
fi

echo ""
echo "=== Summary ==="
if [ "$ERRORS" -eq 0 ]; then
  echo -e "${GREEN}Validation passed${NC}: All routing checks passed"
  exit 0
else
  echo -e "${RED}Validation failed${NC}: $ERRORS error(s) found"
  exit 1
fi
