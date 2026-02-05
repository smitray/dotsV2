---
name: zsh-path-skill
description: Comprehensive guidance for managing PATH environment variables in zsh, including troubleshooting missing commands, adding new tools, and organizing shell configuration.
license: MIT
allowed-tools: Bash, Zsh
---

# Zsh PATH Management Skill

This skill provides comprehensive guidance for managing PATH environment variables in zsh, including troubleshooting missing commands, adding new tools, and organizing shell configuration.

## When to Use This Skill
- Getting "command not found" errors for installed tools
- Adding new tools to PATH (bun, nvm, cargo, go, Python venv, etc.)
- Validating and auditing current PATH entries
- Organizing PATH configuration between `.zshrc` and `.zshrc.local`
- Troubleshooting shell startup issues related to PATH

## Diagnostic Commands

### Check Current PATH
```bash
# List all PATH entries
echo $PATH | tr ':' '\n'

# Check if specific command is in PATH
which bun 2>/dev/null || echo "bun not found in PATH"

# Find where a command is installed
command -v node
type -a python
```

### Validate PATH Entries
```bash
# Check for broken/non-existent PATH entries
echo $PATH | tr ':' '\n' | while read p; do [[ -d "$p" ]] || echo "MISSING: $p"; done

# Check for duplicate PATH entries
echo $PATH | tr ':' '\n' | sort | uniq -d
```