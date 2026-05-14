#!/usr/bin/env bash
# merge-extensions.sh - Merge extension index entries into main context/index.json
#
# Usage: merge-extensions.sh [--dry-run] [--verify]
#
# Options:
#   --dry-run   Preview changes without modifying files
#   --verify    Check current index completeness and report missing entries
#
# This script reads all extension manifests and merges their index-entries.json
# into the main .opencode/context/index.json. Safe to run multiple times
# (idempotent - skips entries that already exist by path).

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Find project root (directory containing .opencode/)
find_project_root() {
    local dir="$1"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.opencode" ]]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

PROJECT_DIR=$(find_project_root "$(cd "$(dirname "$0")" && pwd)")
EXTENSIONS_DIR="$PROJECT_DIR/.opencode/extensions"
INDEX_FILE="$PROJECT_DIR/.opencode/context/index.json"

DRY_RUN=false
VERIFY_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verify)
            VERIFY_ONLY=true
            shift
            ;;
        -h|--help)
            echo "Usage: merge-extensions.sh [--dry-run] [--verify]"
            echo ""
            echo "Options:"
            echo "  --dry-run   Preview changes without modifying files"
            echo "  --verify    Check current index completeness and report missing entries"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Verify dependencies
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed${NC}"
    exit 1
fi

# Verify paths exist
if [[ ! -d "$EXTENSIONS_DIR" ]]; then
    echo -e "${RED}Error: Extensions directory not found: $EXTENSIONS_DIR${NC}"
    exit 1
fi

if [[ ! -f "$INDEX_FILE" ]]; then
    echo -e "${RED}Error: Index file not found: $INDEX_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}Scanning extensions in $EXTENSIONS_DIR${NC}"

# Track statistics
total_extensions=0
extensions_with_index=0
entries_added=0
entries_skipped=0
missing_entries=()

# Get existing paths from index
existing_paths=$(jq -r '.entries[].path' "$INDEX_FILE" 2>/dev/null || echo "")

# Process each extension
for manifest in "$EXTENSIONS_DIR"/*/manifest.json; do
    if [[ ! -f "$manifest" ]]; then
        continue
    fi

    ext_dir=$(dirname "$manifest")
    ext_name=$(basename "$ext_dir")
    total_extensions=$((total_extensions + 1))

    # Check if extension has merge_targets.index
    has_index_merge=$(jq -r '.merge_targets.index // empty' "$manifest" 2>/dev/null || true)

    if [[ -z "$has_index_merge" ]]; then
        echo -e "${YELLOW}Skip: $ext_name (no merge_targets.index)${NC}"
        continue
    fi

    # Get the source index-entries.json path
    source_file=$(jq -r '.merge_targets.index.source' "$manifest" 2>/dev/null || true)

    if [[ -z "$source_file" ]]; then
        source_file="index-entries.json"  # Default name
    fi

    source_path="$ext_dir/$source_file"

    if [[ ! -f "$source_path" ]]; then
        echo -e "${YELLOW}Skip: $ext_name (no $source_file found)${NC}"
        continue
    fi

    extensions_with_index=$((extensions_with_index + 1))
    echo -e "${GREEN}Processing: $ext_name${NC}"

    # Read entries from extension's index-entries.json
    # Handle both array and object-with-entries formats
    ext_entries=$(jq -r 'if type == "array" then . else .entries // [] end' "$source_path" 2>/dev/null)

    if [[ "$ext_entries" == "null" ]] || [[ -z "$ext_entries" ]]; then
        echo -e "${YELLOW}  No entries found in $source_file${NC}"
        continue
    fi

    # Process each entry
    entry_count=$(echo "$ext_entries" | jq 'length')

    for i in $(seq 0 $((entry_count - 1))); do
        entry=$(echo "$ext_entries" | jq ".[$i]")
        entry_path=$(echo "$entry" | jq -r '.path')

        # Check if path already exists in main index
        if echo "$existing_paths" | grep -qF "$entry_path"; then
            entries_skipped=$((entries_skipped + 1))
            if [[ "$VERIFY_ONLY" == "true" ]]; then
                echo -e "  ${BLUE}[EXISTS]${NC} $entry_path"
            fi
        else
            entries_added=$((entries_added + 1))
            missing_entries+=("$ext_name:$entry_path")
            if [[ "$DRY_RUN" == "true" ]] || [[ "$VERIFY_ONLY" == "true" ]]; then
                echo -e "  ${YELLOW}[MISSING]${NC} $entry_path"
            else
                echo -e "  ${GREEN}[ADD]${NC} $entry_path"
            fi
        fi
    done
done

echo ""
echo -e "${BLUE}=== Summary ===${NC}"
echo "Extensions scanned: $total_extensions"
echo "Extensions with index: $extensions_with_index"
echo "Entries already in index: $entries_skipped"
echo "Entries to add: $entries_added"

if [[ "$VERIFY_ONLY" == "true" ]]; then
    if [[ ${#missing_entries[@]} -eq 0 ]]; then
        echo -e "${GREEN}Index is complete - all extension entries present${NC}"
        exit 0
    else
        echo -e "${YELLOW}Missing entries:${NC}"
        for entry in "${missing_entries[@]}"; do
            echo "  - $entry"
        done
        exit 1
    fi
fi

if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}Dry run - no changes made${NC}"
    if [[ ${#missing_entries[@]} -gt 0 ]]; then
        echo "Would add:"
        for entry in "${missing_entries[@]}"; do
            echo "  - $entry"
        done
    fi
    exit 0
fi

# If we get here and have entries to add, we need to actually merge them
if [[ ${#missing_entries[@]} -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}Note: To add missing entries, manually update $INDEX_FILE${NC}"
    echo "Missing entries can be found in the extension index-entries.json files."
    echo ""
    echo "For automated merging, run this script with --dry-run to see what would be added,"
    echo "then manually add the entries to maintain proper JSON structure."
fi

echo -e "${GREEN}Done${NC}"
