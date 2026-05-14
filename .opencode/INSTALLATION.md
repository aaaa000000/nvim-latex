# Installation Guide

This guide covers the installation and setup of the .opencode/ agent orchestration system for Neovim configuration management.

## Prerequisites

Before installing the .opencode/ system, ensure you have the following dependencies:

### Required Software

- **Neovim** (latest stable, >= 0.9.0)
  - Required for Lua configuration and plugin integration
  - Install via package manager or [GitHub releases](https://github.com/neovim/neovim/releases)

- **Git** (>= 2.30.0)
  - Required for repository operations and task tracking
  - Standard system package

- **Bash** (>= 4.0)
  - Required for command execution scripts
  - Standard on most Linux/macOS systems

- **jq** (>= 1.6)
  - Required for JSON state manipulation
  - Install: `apt-get install jq` (Debian/Ubuntu), `brew install jq` (macOS)

### Optional Dependencies

- **GitHub CLI** (`gh`)
  - Useful for repository operations and pull requests
  - Install: [GitHub CLI documentation](https://cli.github.com/)

- **fd** and **ripgrep** (`rg`)
  - Enhanced file finding and searching (used by some commands)
  - Install: `apt-get install fd-find ripgrep` or `brew install fd ripgrep`

## Installation

### Step 1: Clone the Repository

If you haven't already set up the Neovim configuration:

```bash
# Clone to your Neovim config directory
git clone <repository-url> ~/.config/nvim
cd ~/.config/nvim
```

### Step 2: Verify Directory Structure

Ensure the `.opencode/` directory exists with the following structure:

```
.opencode/
├── agent/        # Primary agents and subagents
├── commands/     # Slash command definitions
├── context/      # Core and project context
├── docs/         # User-facing documentation
├── hooks/        # Hook scripts used by tooling
├── rules/        # System rules and conventions
├── skills/       # Skill definitions
├── systemd/      # Service definitions for refresh automation
└── templates/    # JSON and markdown templates
```

### Step 3: Verify Dependencies

Check that required tools are available:

```bash
# Check Neovim
nvim --version

# Check Git
git --version

# Check Bash
bash --version

# Check jq
jq --version
```

### Step 4: Test Command Access

Verify the opencode commands are accessible:

```bash
# These should display help text
/task --help
/research --help
/plan --help
/implement --help
```

## Quick Commands

Once installed, try these essential commands:

### Task Management
```bash
# Create a new task
/task "Your task description"

# Research an existing task
/research TASK_NUMBER

# Create implementation plan
/plan TASK_NUMBER

# Execute implementation
/implement TASK_NUMBER
```

### Lean 4 Projects (if applicable)
```bash
# Check Lean toolchain
/lean --check

# Build project
/lake --help
```

## Troubleshooting

### Common Issues

**"command not found" errors**
- Ensure Neovim is properly installed and in your PATH
- Check that the `.opencode/` directory exists in your nvim config

**jq errors**
- Install jq: `apt-get install jq` (Debian/Ubuntu), `brew install jq` (macOS)
- Verify with: `jq --version`

**Git issues**
- Ensure Git is configured with user.name and user.email
- Check with: `git config --list`

### Verification Steps

After installation, verify everything works:

1. **Check state.json is readable**:
   ```bash
   cat ~/.config/nvim/specs/state.json | jq '.next_project_number'
   ```

2. **Check TODO.md exists**:
   ```bash
   cat ~/.config/nvim/specs/TODO.md | head -20
   ```

3. **Test task creation** (dry run):
   ```bash
   # This will show help without creating a task
   /task --help
   ```

## Next Steps

After successful installation:

1. Read the [full README](../README.md) for comprehensive system documentation
2. Review [command reference](../commands/README.md) for detailed command syntax
3. Check [architecture overview](../docs/architecture/system-overview.md) for system design

## Support

For issues or questions:
- Check the [documentation](../docs/README.md)
- Review [troubleshooting section](#troubleshooting)
- Examine the [error handling guide](../rules/error-handling.md)
